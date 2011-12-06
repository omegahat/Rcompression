#include "miniunzip.h"

#include <Rinternals.h>
#include <Rdefines.h>

#include "RConverters.h"


/* machine generated from  cat(createCopyStruct(types$unz_file_info)). See tuNotes file. */
SEXP R_copyStruct_tm_unz (tm_unz *value) ;
SEXP R_copyStruct_unz_global_info ( unz_global_info   *value) ;


SEXP R_copyStruct_unz_file_info ( unz_file_info   *value) 
{
	 SEXP r_ans = R_NilValue, klass;
	 klass = MAKE_CLASS("unz_file_info");
	 if(klass == R_NilValue) {
	    PROBLEM "Cannot find R class unz_file_info "
	     ERROR;
	 }
	 

	 PROTECT(klass);
	 PROTECT(r_ans = NEW(klass));

	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("version"), ScalarReal ( value -> version ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("version_needed"), ScalarReal ( value -> version_needed ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("flag"), ScalarReal ( value -> flag ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("compression_method"), ScalarReal ( value -> compression_method ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("dosDate"), ScalarReal ( value -> dosDate ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("crc"), ScalarReal ( value -> crc ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("compressed_size"), ScalarReal ( value -> compressed_size ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("uncompressed_size"), ScalarReal ( value -> uncompressed_size ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("size_filename"), ScalarReal ( value -> size_filename ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("size_file_extra"), ScalarReal ( value -> size_file_extra ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("size_file_comment"), ScalarReal ( value -> size_file_comment ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("disk_num_start"), ScalarReal ( value -> disk_num_start ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("internal_fa"), ScalarReal ( value -> internal_fa ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("external_fa"), ScalarReal ( value -> external_fa ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("tmu_date"), R_copyStruct_tm_unz( &value -> tmu_date ) ));
	 UNPROTECT( 17 );
	 
	 return(r_ans);
}

SEXP R_copyStruct_tm_unz (tm_unz *value) 
{
	 SEXP r_ans = R_NilValue, klass;
	 klass = MAKE_CLASS("tm_unz");
	 if(klass == R_NilValue) {
	    PROBLEM "Cannot find R class tm_unz "
	     ERROR;
	 }
	 

	 PROTECT(klass);
	 PROTECT(r_ans = NEW(klass));

	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("tm_sec"), ScalarInteger( value -> tm_sec ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("tm_min"), ScalarInteger( value -> tm_min ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("tm_hour"), ScalarInteger( value -> tm_hour ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("tm_mday"), ScalarInteger( value -> tm_mday ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("tm_mon"), ScalarInteger( value -> tm_mon ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("tm_year"), ScalarInteger( value -> tm_year ) ));
	 UNPROTECT( 8 );
	 
	 return(r_ans);
}


SEXP R_copyStruct_unz_global_info ( unz_global_info   *value) 
{
	 SEXP r_ans = R_NilValue, klass;
	 klass = MAKE_CLASS("unz_global_info");
	 if(klass == R_NilValue) {
	    PROBLEM "Cannot find R class unz_global_info "
	     ERROR;
	 }
	 

	 PROTECT(klass);
	 PROTECT(r_ans = NEW(klass));

	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("number_entry"), ScalarInteger( value -> number_entry ) ));
	 PROTECT(r_ans = SET_SLOT(r_ans, Rf_install("size_comment"), ScalarInteger( value -> size_comment ) ));
	 UNPROTECT( 4 );
	 
	 return(r_ans);
}


SEXP
R_unzOpen(SEXP r_r976)
{

    SEXP r_ans = R_NilValue;
   const char * r976 ;
unzFile ans ;

    r976  =  CHAR(STRING_ELT( r_r976 , 0)) ;

    ans =   unzOpen ( r976 ) ;
    r_ans =  R_MAKE_REF_TYPE( (void *)  ans ,  unzFileRef ) ;

    return(r_ans);
}

SEXP
R_unzClose(SEXP r_r274)
{

    SEXP r_ans = R_NilValue;
   unzFile r274 ;
int ans ;

    r274  =  DEREF_REF_PTR_CLASS( r_r274 ,  unzFile, unzContent ) ;

    ans =   unzClose ( r274 ) ;
    r_ans =  ScalarInteger( ans ) ;

    return(r_ans);
}

/*
Generated code
SEXP
R_unzGetGlobalInfo(SEXP r_r873, SEXP r_r905)
{

    SEXP r_ans = R_NilValue;
   unzFile r873 ;
   unz_global_info * r905 ;
int ans ;

    r873  =  DEREF_REF( r_r873 ,  unzFile ) ;
    r905  =  R_GET_REF_TYPE( r_r905 ,  unz_global_info  ); ;

    ans =   unzGetGlobalInfo ( r873, r905 ) ;
    r_ans =  ScalarInteger( ans ) ;

    return(r_ans);
}
*/
#if 0
/* Hand fixed code. */
SEXP
R_unzGetGlobalInfo(SEXP r_r873, SEXP r_r905)
{

    SEXP r_ans = R_NilValue;
   unzFile r873 ;
   unz_global_info  r905 ;
   int ans ;

    r873  =  DEREF_REF_PTR( r_r873 ,  unzContent ) ;
    ans =   unzGetGlobalInfo ( r873, &r905 ) ;
    PROTECT(r_ans = NEW_LIST(2));
    SET_VECTOR_ELT(r_ans, 0, ScalarInteger( ans ) );
    SET_VECTOR_ELT(r_ans, 1, R_copyStruct_unz_global_info(&r905));  
    /* names */
    UNPROTECT(1);

    return(r_ans);
}
#endif



SEXP
R_unzGetGlobalInfo(SEXP r_file)
{

    SEXP r_ans = R_NilValue;
unz_global_info pglobal_info ;
   unzFile file ;
     int ans ;

    file  =  DEREF_REF_PTR_CLASS( r_file ,  unzFile, unzContent) ;

    ans =   unzGetGlobalInfo ( file, & pglobal_info ) ;
	 PROTECT(r_ans = NEW_LIST( 2 ));
	 SET_VECTOR_ELT(r_ans, 0,  ScalarInteger( ans ) );
	 SET_VECTOR_ELT( r_ans, 1 ,  R_copyStruct_unz_global_info( &pglobal_info ) );
	 {
	 const char *names[] = {
	 		"",
		"pglobal_info"
	 	};
	 SET_NAMES(r_ans, R_makeNames(names,  2 ));
	 };
	 UNPROTECT( 1 );

    return(r_ans);
}


SEXP
R_unzGetCurrentFileInfo(SEXP r_file, SEXP r_szFileName, SEXP r_fileNameBufferSize, SEXP r_extraField, SEXP r_extraFieldBufferSize, SEXP r_szComment, SEXP r_commentBufferSize)
{

    SEXP r_ans = R_NilValue;
unz_file_info pfile_info ;
   unzFile file ;
   const char * szFileName ;
   uLong fileNameBufferSize ;
   void * extraField ;
   uLong extraFieldBufferSize ;
   const char * szComment ;
   uLong commentBufferSize ;
     int ans ;

        file  =  DEREF_REF_PTR_CLASS( r_file ,  unzFile, unzContent ) ;
        szFileName  =  GET_LENGTH( r_szFileName ) > 0 ? CHAR(STRING_ELT( r_szFileName , 0)) :  NULL ;
        fileNameBufferSize  =  INTEGER( r_fileNameBufferSize )[0] ;
        extraField  =  TYPEOF( r_extraField ) == RAWSXP ?  (GET_LENGTH( r_extraField ) ? RAW( r_extraField ) : NULL) : R_getNativeReference( r_extraField , NULL, NULL) ;
        extraFieldBufferSize  =  INTEGER( r_extraFieldBufferSize )[0] ;
        szComment  =  GET_LENGTH( r_szComment ) > 0 ? CHAR(STRING_ELT( r_szComment , 0)) :  NULL ;
        commentBufferSize  =  INTEGER( r_commentBufferSize )[0] ;

    ans =   unzGetCurrentFileInfo ( file, & pfile_info, szFileName, fileNameBufferSize, extraField, extraFieldBufferSize, szComment, commentBufferSize ) ;
	 PROTECT(r_ans = NEW_LIST( 5 ));
	 SET_VECTOR_ELT(r_ans, 0,  ScalarInteger( ans ) );
	 SET_VECTOR_ELT( r_ans, 1 ,  R_copyStruct_unz_file_info( &pfile_info ) );
	 SET_VECTOR_ELT( r_ans, 2 ,  mkString( szFileName  ?  szFileName : "") );
	 SET_VECTOR_ELT( r_ans, 3 ,  R_MAKE_REF_TYPE( (void *)  extraField ,  voidRef ) );
	 SET_VECTOR_ELT( r_ans, 4 ,  mkString( szComment && szComment[0] ?  szComment : "") );
	 {
	 const char *names[] = {
	 		"",
		"pfile_info",
		"szFileName",
		"extraField",
		"szComment"
	 	};
	 SET_NAMES(r_ans, R_makeNames(names,  5 ));
	 };
	 UNPROTECT( 1 );

    return(r_ans);
}

#if 0
SEXP
R_unzGetCurrentFileInfo(SEXP r_r555, SEXP r_r588, SEXP r_r620, SEXP r_r653, SEXP r_r691, SEXP r_r730, SEXP r_r762, SEXP r_r798)
{

    SEXP r_ans = R_NilValue;
   unzFile r555 ;
   unz_file_info r588 ;
   char  r620[256] ;
   uLong r653 = 256;
   void * r691 = NULL;
   uLong r730 ;
   char * r762 = NULL;
   uLong r798 ;
int ans ;

    r555  =  DEREF_REF_PTR( r_r555 ,  unzFile ) ;
   /*
    r588  =  R_GET_REF_TYPE( r_r588 ,  unz_file_info  ); ;
    r620  =  CHAR(STRING_ELT( r_r620 , 0)) ;
    r653  =  INTEGER( r_r653 )[0] ;
    r691  =  NA ( r_r691 ) ;
    r730  =  INTEGER( r_r730 )[0] ;
    r762  =  CHAR(STRING_ELT( r_r762 , 0)) ;
    r798  =  INTEGER( r_r798 )[0] ;
    */
    ans =   unzGetCurrentFileInfo ( r555, &r588, r620, r653, r691, r730, r762, r798 ) ;

    PROTECT(r_ans = NEW_LIST(3));
    SET_VECTOR_ELT(r_ans, 0, ScalarInteger( ans ) );
    SET_VECTOR_ELT(r_ans, 1, R_copyStruct_unz_file_info(&r588));  
    SET_VECTOR_ELT(r_ans, 2, mkString(r620));
    /* names */
    UNPROTECT(1);


    return(r_ans);
}
#endif


SEXP
R_unzGoToFirstFile(SEXP r_r274)
{

    SEXP r_ans = R_NilValue;
   unzFile r274 ;
int ans ;

    r274  =  DEREF_REF_PTR_CLASS( r_r274 ,  unzFile, unzContent ) ;

    ans =   unzGoToFirstFile ( r274 ) ;
    r_ans =  ScalarInteger( ans ) ;

    return(r_ans);
}



SEXP
R_unzGoToNextFile(SEXP r_r274)
{

    SEXP r_ans = R_NilValue;
   unzFile r274 ;
int ans ;

    r274  =  DEREF_REF_PTR_CLASS( r_r274 ,  unzFile, unzContent ) ;

    ans =   unzGoToNextFile ( r274 ) ;
    r_ans =  ScalarInteger( ans ) ;

    return(r_ans);
}


