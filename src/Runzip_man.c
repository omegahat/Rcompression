#include "miniunzip.h"

#include <Rinternals.h>
#include <Rdefines.h>

#include "RConverters.h"

SEXP
R_unzOpenCurrentFilePassword(SEXP r_unzFile, SEXP r_password)
{
  unzFile f =  DEREF_REF_PTR_CLASS( r_unzFile,  unzFile, unzContent );
  int err;
  const char * password = NULL;
  if(GET_LENGTH(r_password))
    password = CHAR(STRING_ELT(r_password, 0));

  err = unzOpenCurrentFilePassword(f, password);
  return(ScalarInteger(err));
}

SEXP
R_unzReadCurrentFile(SEXP r_unzFile, SEXP r_buf, SEXP r_numBytes)
{
  unzFile f =  DEREF_REF_PTR_CLASS( r_unzFile,  unzFile, unzContent );
  int err = UNZ_OK;
  void *buf;
  int numBytes;

  numBytes = REAL(r_numBytes)[0];

  buf = TYPEOF(r_buf) == RAWSXP ? RAW(r_buf) : (void*) CHAR(STRING_ELT(r_buf, 0));

  err = unzReadCurrentFile(f, buf, numBytes);

  return(ScalarLogical(err > 0));
}
