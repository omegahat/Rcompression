
#define R_UNTGZ
#include "untgz.h"
#include <Rinternals.h>
#include <R_ext/RS.h>
#include <Rdefines.h>


#include "Rtar.h"

/* data, time, size, file. */

typedef struct {
    SEXP e;
    SEXP rawData;
    unsigned offset;
    int numProtects;
} RTarCallInfo;


void 
R_tarInfo_callback(int counter, char typeflag, time_t time, const char *fname, int remaining, void *data)
{
    RTarCallInfo *cb = (RTarCallInfo *) data;
    SEXP p;
    char buf[2] = "a";
    int tt;

#if 0
    fprintf(stderr, "%d %c %s %d\n", counter, typeflag, fname, remaining);
#endif


    p = CDR(cb->e);
    SET_STRING_ELT(CAR(p), 0, mkChar(fname)); p = CDR(p);
#if 0
    SET_STRING_ELT(CAR(p), 0, mkChar(TypeNames[typeflag])); p = CDR(p);
#else
    buf[0] = typeflag;
    tt = TYPEOF(CAR(p));
    SET_STRING_ELT(CAR(p), 0, mkChar(buf));  p = CDR(p);
#endif
    REAL(CAR(p))[0] = time; p = CDR(p); 
    INTEGER(CAR(p))[0] = remaining;  p = CDR(p); 
    INTEGER(CAR(p))[0] = counter;

    Rf_eval(cb->e, R_GlobalEnv);

    return;
}

SEXP
R_tarInfo(SEXP r_filename,  SEXP r_fun, SEXP r_data)
{
   gzFile *f = NULL;
   const char *filename;
   char *argv[] = {"R"};
   TarCallbackFun callback = R_tarInfo_callback;
   RTarCallInfo rcb;
   Rboolean doRcallback = (TYPEOF(r_fun) == CLOSXP);
   void *data;

   if(TYPEOF(r_filename) == STRSXP) {
       filename = CHAR(STRING_ELT(r_filename, 0));
       f = gzopen(filename, "rb");

       if(!f) {
	   PROBLEM "Can't open file %s", filename
	       ERROR;
       }
   }

   if(doRcallback) {

       SEXP p;
       PROTECT(rcb.e = p = allocVector(LANGSXP, 6));
       SETCAR(p, r_fun); p = CDR(p);
       SETCAR(p, allocVector(STRSXP, 1)); p = CDR(p); /* file */
       SETCAR(p, mkString("a")); p = CDR(p); /* type flag */
       SETCAR(p, allocVector(REALSXP, 1)); p = CDR(p); /* time */
       SETCAR(p, allocVector(INTSXP, 1)); p = CDR(p); /* remaining */
       SETCAR(p, allocVector(INTSXP, 1)); p = CDR(p); /* counter */

       data = (void *) &rcb;

   } else {

       data = (void *) r_data;
       callback = (TarCallbackFun) R_ExternalPtrAddr(r_fun);

   }

   if(f) {
       tar(f, TGZ_LIST, 1, sizeof(argv)/sizeof(argv[0]), argv, callback, (void *) data);
   } else {
       DataSource src;
       R_rawStream stream;
       stream.data = RAW(r_filename);
       stream.len = LENGTH(r_filename);
       stream.pos = 0;

       src.data = &stream;
       src.throwError = rawError;
       src.read = rawRead;
       funTar(&src, TGZ_LIST, 1, sizeof(argv)/sizeof(argv[0]), argv, callback, (void *) data);
   }

   if(doRcallback) 
       UNPROTECT(1);

   if (f && gzclose(f) != Z_OK)
      error("failed gzclose");

   return(R_NilValue);
}


/*
 The simplest version of this is that r_fun is NULL
 and that we are charged with collecting all the file contents
 ourself.
 A more complex version is that we have a function that is called
 whenever we have completed a full file extraction and this allows
 the R user to process the file immediately and then discard the
 contents. This is more efficient.
 Another approach is to let there be a function for each file name
 so that we could have specialized readers for different file types.
 We can do this in a single R function so it is not essential we do it
 here in the code.


 We can do a lot of this in R however.


TODO   XXX
 We could make this quite a bit faster in "some" (possibly most)
 by knowing what the correct size of the raw vector should be
 before we start and pre-allocating it. How much this will speed 
 things up depends on the size of the chunks being passed here.
 The fewer there are, the less often we reallocate the raw vector
 and copy.
 The information about the size of the file can be computed
 using tarInfo() although this would require two passes.
 (It would be nice to be able to jump to a particular byte in the archive and start from
  there.)
 We would need a hash table of entry name -> size or alternatively
 just use one large raw vector that will hold the largest entry.
*/

void
R_tarCollectContents(const char *fname, char *bytes, unsigned int numBytes, unsigned int remaining, void *data)
{
    RTarCallInfo *cb = (RTarCallInfo *)data;
    int len = 0;

    if(numBytes < 1) {
	/* Invoke the function to signal the completion of a file. */

        /* Need to make this have the correct length, i.e. cb->offset */
        SEXP tmp = cb->rawData;
        if(GET_LENGTH(cb->rawData) > cb->offset) {
 	    tmp = allocVector(RAWSXP, cb->offset); /* shouldn't need to protect. */
	    memcpy(RAW(tmp), RAW(cb->rawData), cb->offset);
	}
	SETCAR(CDR(cb->e), tmp);
	SETCAR(CDR(CDR(cb->e)), mkString(fname));
	Rf_eval(cb->e, R_GlobalEnv);

	cb->offset = 0;
	
	return;
    }

    /* If we don't preallocate rawData, then this will continue
       to grow the vector just enough to fit the new bytes.*/
    if(cb->rawData == R_NilValue) 
	cb->rawData = allocVector(RAWSXP, numBytes);
    else {
	len = LENGTH(cb->rawData);
        if(len - cb->offset < numBytes) {
	    SET_LENGTH(cb->rawData, len + numBytes);
	    PROTECT(cb->rawData); 
	    cb->numProtects++;
	}
    }

    memcpy(RAW(cb->rawData) + cb->offset, bytes, numBytes);
    cb->offset += numBytes;
}


SEXP
R_tarExtract(SEXP r_filename,  SEXP r_filenames, SEXP r_fun, SEXP r_data,
             SEXP r_workBuf)
{
   TarExtractCallbackFun callback = R_tarCollectContents;
   RTarCallInfo rcb;
   Rboolean doRcallback = (TYPEOF(r_fun) == CLOSXP);
   void *data;

   gzFile *f = NULL;

   int numFiles = LENGTH(r_filenames), i;
   const char **argv;
   int argc = numFiles + 1;

   if(TYPEOF(r_filename) == STRSXP) {
       const char *filename;
       filename = CHAR(STRING_ELT(r_filename, 0));
       f = gzopen(filename, "rb");

       if(!f) {
	   PROBLEM "Can't open file %s", filename
	       ERROR;
       }
   }

   if(doRcallback) {

       SEXP p;

       rcb.rawData = r_workBuf;
       rcb.numProtects = 0;
       rcb.offset = 0;
				 

       PROTECT(rcb.e = p = allocVector( LANGSXP, 3));
       SETCAR(p, r_fun);

       callback = R_tarCollectContents;

       data = (void *) &rcb;

   } else {
       data = (void *) r_data;
       callback = (TarExtractCallbackFun) R_ExternalPtrAddr(r_fun);
   }

   argv = (char **) S_alloc(numFiles + 1, sizeof(char *));
   argv[0] = "R";
   for(i = 1; i < numFiles + 1; i++)
       argv[i] = CHAR(STRING_ELT(r_filenames, i-1));


   if(TYPEOF(r_filename) == STRSXP)
      tar(f, TGZ_EXTRACT, numFiles + 1, argc, argv, (TarCallbackFun) callback, (void *) data);
   else {
       DataSource src;
       R_rawStream stream;
       stream.data = RAW(r_filename);
       stream.len = LENGTH(r_filename);
       stream.pos = 0;

       src.data = &stream;
       src.throwError = rawError;
       src.read = rawRead;
       funTar(&src, TGZ_EXTRACT, numFiles + 1, argc, argv, (TarCallbackFun) callback, (void *) data);
   }

   if(doRcallback) 
       UNPROTECT(1);
   if(rcb.numProtects > 0)
       UNPROTECT(rcb.numProtects);

   if (f && gzclose(f) != Z_OK)
      error("failed gzclose");

   return(R_NilValue);
}




#include <Rdefines.h>

/* Routine to get map from the typeflag values to human
   readable names.
 */
SEXP
R_getTarTypeNames()
{
    SEXP ans, names;
    int i, n;

    n = sizeof(TypeValues)/sizeof(TypeValues[0]);

    PROTECT(ans = NEW_CHARACTER(n));
    PROTECT(names = NEW_CHARACTER(n));
    for(i = 0; i < n ; i++) {
	char buf[2] = "a";
	buf[0] = TypeValues[i];
	SET_STRING_ELT(ans, i, mkChar(buf));
	SET_STRING_ELT(names, i, mkChar(TypeNames[i]));
    }
    SET_NAMES(ans, names);
    UNPROTECT(2);
    
    return(ans);
}
