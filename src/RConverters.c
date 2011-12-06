#include "RConverters.h"
#include "Rdefines.h"


SEXP
R_createNativeReference(void *val, const char *className, const char *tagName)
{
 SEXP ans;
 SEXP klass = MAKE_CLASS((char *) className);

 if(klass == R_NilValue) {
	 PROBLEM "Can't find class %s", className
    ERROR;
 }

 PROTECT(klass);
 PROTECT(ans = NEW(klass));

 ans = SET_SLOT(ans, Rf_install("ref"),  R_MakeExternalPtr(val, Rf_install(tagName), R_NilValue));

 UNPROTECT(2);
 return(ans);
}

void *
R_getNativeReference(SEXP arg, const char *type, const char *tag)
{
 SEXP el = GET_SLOT(arg, Rf_install("ref"));
 void *ans;
 if(R_ExternalPtrTag(el) != Rf_install(tag)) {

        /* So not a direct match. Now see if it is from a derived class
           by comparing the value in the object to the name of each of the
           ancestor classes.
         */
    SEXP ancestors = GET_SLOT(arg, Rf_install("classes"));
    int n, i;
    n = Rf_length(ancestors);
    for(i = 0; i < n  ; i ++) {
        if(strcmp(CHAR(STRING_ELT(ancestors, i)), tag) == 0)
  	   break;
    }
    if(i == n) {
      PROBLEM "Looking for %s, got %s",
	      type, CHAR(PRINTNAME(R_ExternalPtrTag(el)))
      ERROR;
    }
 }

 ans = R_ExternalPtrAddr(el);

 if(!ans) {
   PROBLEM "NULL value passed to R_getNativeReference. This may not be an error, but it could be very serious!"
   ERROR;
 }
 return(ans);
}


int
convertFromRToInt(SEXP obj)
{
    return(INTEGER(obj)[0]);
}


SEXP
convertIntToR(int x)
{
    SEXP ans;
    ans = allocVector(INTSXP, 1);
    INTEGER(ans)[0] = x;
    return(ans);
}

SEXP
convertDoubleToR(double x)
{
    SEXP ans;
    ans = allocVector(REALSXP, 1);
    REAL(ans)[0] = x;
    return(ans);
}


SEXP
convertIntArrayToR(int *x, int len)
{
    SEXP ans;
    int i;
    
    ans = allocVector(INTSXP, len);
    for(i = 0; i < len ; i++)
	INTEGER(ans)[i] = x[i];
    return(ans);
}



SEXP
convertStringArrayToR(const char *x[], int len)
{
    SEXP ans;
    int i;
    
    PROTECT(ans = allocVector(STRSXP, len));
    for(i = 0; i < len ; i++)
	SET_STRING_ELT(ans, i, mkChar(x[i] ? x[i] : ""));
    UNPROTECT(1);
    return(ans);
}



SEXP
createREnumerationValue(int val, const char * const *names, const int *values, int namesLength, const char *name)
{
    SEXP ans;
    int i;

    PROTECT(ans =allocVector(INTSXP, 1));
    INTEGER(ans)[0] = val;
    
    for(i = 0; i < namesLength; i++) {
	if(val == values[i]) {
	    SET_NAMES(ans, mkString(names[i]));
	    break;
	}
    }

    if(i == namesLength) {
	PROBLEM "Unrecognized value (%d) in enumeration %s", val, name
        ERROR;
    }
    /* Do we want an enumeration value element here also. */
    SET_CLASS(ans, mkString(name));

    Rf_PrintValue(ans);

    UNPROTECT(1);
    return(ans);
}


/*
  Finalize for deallocating the space we allocate for references to structures
  created in S as part of the automatically generated code.
 */
void
SimpleAllocFinalizer(SEXP ans)
{
    void *ptr = R_ExternalPtrAddr(ans);
    if(ptr) {
	fprintf(stderr, "Finalizing %p\n", ptr); fflush(stderr);
	free(ptr);
    }
}

/**
  Convert R object into either a function or the address of a C routine.
  For a C routine, the caller can specify the name of the typedef which is
  checked using the TAG for the external pointer.
*/
void *
Rfrom_Callbable(SEXP obj, const char * const TypeDefName, CallableType *type) 
{

           /* If TypeDefName is NULL, we don't bother checking*/
        if(TYPEOF(obj) == EXTPTRSXP) {
	    if(TypeDefName && R_ExternalPtrTag(obj) != Rf_install(TypeDefName)) {
   	         PROBLEM "[RfromCallbable] incorrect type name for a native routine pointer %s, not %s",
		    CHAR(asChar(R_ExternalPtrTag(obj))), TypeDefName
		 ERROR;
	    }

	    if(type) 
		*type = NATIVE_ROUTINE;

	    return(R_ExternalPtrAddr(obj));
        } else if(TYPEOF(obj) == CLOSXP) {
	    if(type) 
		*type = R_FUNCTION;
	    return(obj);
	}

	PROBLEM  "the Rfrom_Callable routine only handles native routines and "
        ERROR;

	return((void *) NULL);
   }


SEXP
R_makeNames(const char *names[], int len)
{
  SEXP ans;
  int i;
  PROTECT(ans = NEW_CHARACTER(len));
  for(i = 0; i < len; i++) 
    SET_STRING_ELT(ans, i, mkChar(names[i]));
  UNPROTECT(1);

  return(ans);
}

typedef struct {
    void **els;
    unsigned long length;
} RPointerList;

SEXP
R_listToRefArray(SEXP r_els, SEXP r_type)
{
    const char *type;
    SEXP el;
    int i, n;
    void *tmp;
    RPointerList *ans;
    
    n = GET_LENGTH(r_els);
    ans = (RPointerList *) malloc(sizeof(RPointerList));
    ans->els = (void **) malloc(sizeof(void *) * n);

    for(i = 0; i < n; i++) {
	el = VECTOR_ELT(r_els, i);
	tmp = R_getNativeReference(el, type, type);
	ans->els[i] = tmp;
    }
    /*XXX Need finalizer */
    return(R_MAKE_REF_TYPE(ans, RPointerList));
}


SEXP
R_RPointerList_length(SEXP r_ref)
{
    RPointerList *l = R_GET_REF_TYPE(r_ref, RPointerList);
    return(ScalarReal(l->length));
}


char **
getRStringArray(SEXP els)
{
    char **ans;
    int i, len;
    
    len = GET_LENGTH(els);
    if(len == 0)
	return(NULL);
    ans = (char **) malloc(sizeof(char *) * len);
    for(i = 0; i < len ; i++)
	ans[i] = strdup(CHAR(STRING_ELT(els, i)));
    return(ans);
}

