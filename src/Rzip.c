#include "miniunzip.h"
#include <Rinternals.h>
#include <Rdefines.h>
#include "RConverters.h"

SEXP
R_unzGetGlobalComment(SEXP r_zipfile)
{
    char val[10000];
    unzFile f;
    SEXP ans;

    f =  DEREF_REF_PTR_CLASS( r_zipfile ,  unzFile, unzContent) ;
    if(unzGetGlobalComment(f, val, sizeof(val)/sizeof(val[0])) && val[0] != '\0')
	ans = mkString(val);
    else
        ans = NEW_CHARACTER(0);

    return(ans);
}
