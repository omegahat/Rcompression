#include <zlib.h>

#include <Rdefines.h>
#include <Rinternals.h>


#include "R_ext/Memory.h"
#include "R_ext/Utils.h"

/*
 This is used to read the result from a request where the result is an
 in-memory gzipped (?really? more like compressed with compress rather than gzip) stream. 
 We arrange to to handle the result and uncompress it.
*/

#define MAX(a, b) ((a) < (b)) ? (b) : (a)

SEXP
R_uncompress(SEXP r_source, SEXP r_guess_size, SEXP asText, SEXP r_resizeBy)
{
  char *ans;
  uLongf destLen = 0;
  uLong sourceLen = (uLong) GET_LENGTH(r_source);
  size_t guess_size = REAL(r_guess_size)[0];
  int status;
  unsigned char *source = RAW(r_source);
  SEXP r_ans ;
  double resizeBy = REAL(r_resizeBy)[0]; 
  
  destLen = guess_size;
  ans = (char *) R_alloc(destLen, sizeof(char));

  do {
      R_CheckUserInterrupt();
      status = uncompress((unsigned char *) ans, &destLen, source, sourceLen);
      if(status == Z_OK) 
	  break;
      else if(status == Z_DATA_ERROR) {
	  PROBLEM "corrupted compressed source"
          ERROR;
      } else if(status == Z_BUF_ERROR) {
    	     /* make certain we get an increased size. For very small
	      * values of resizeBy (e.g. 1.000001) we may end up with
              * the same value.*/
         long newSize = MAX(resizeBy * destLen, destLen + 1);
	 ans = (char *) S_realloc(ans, newSize, destLen, sizeof(char));
         destLen = newSize;
      } else if(status == Z_MEM_ERROR) {
	  PROBLEM "run out of memory during uncompression of (gzip) source"
          ERROR;	  
      }
  } while(1);


  if(LOGICAL(asText)[0]) {
      ans[destLen] = '\0';
      r_ans = mkString(ans);
  } else {
     r_ans = allocVector(RAWSXP, destLen);
     memcpy(RAW(r_ans), ans, destLen);
  }

  return(r_ans);
}

/* Allocation and free routines for the z_stream in zlib. */
static voidpf
R_zlib_alloc(voidpf ptr, uInt items, uInt size)
{
  return(R_alloc(items, size));
}

static void
R_zlib_free(voidpf ptr, voidpf addr)
{
 /* R will free things when we are done. */
}


SEXP
R_zlibVersion ()
{
 SEXP ans;
 ans = mkString(zlibVersion());
 return(ans);
}

/*
<question>
 Notes in gzio.c talk about needing a dummy byte at the end of the stream
 and something about a CRC32. See the call to infalateInit2.

 Also, who reads the header.
<answer>
zlib takes care of this for us at this point.
</answer>
</question>

*/
SEXP
R_gzuncompress(SEXP r_source, SEXP r_guess_size, SEXP asText)
{
 z_stream stream;
 int guess_size;
 char *ans;
 SEXP r_ans;
 int err;
 int len;


 guess_size = REAL(r_guess_size)[0];
 ans = (char *) R_alloc(guess_size, sizeof(char));


 stream.next_in = RAW(r_source);
 stream.avail_in = GET_LENGTH(r_source);
 stream.next_out = (unsigned char *) ans;
 stream.avail_out = guess_size;

 stream.zalloc = R_zlib_alloc;
 stream.zfree = R_zlib_free;
 stream.opaque = NULL;

  /* The MAX_WBITS+16 incantation came from Pascal Scheffers' Tcl bindings for zlib. */
 err = inflateInit2( &stream, MAX_WBITS + 16); 
 if(err != Z_OK) {
  PROBLEM  "cannot establish the uncompres/inflate stream on this data (%d)", err
  ERROR;
 }
  /* inflate the entire thing.  XXX Need to put this in a loop where we extend the output buffer size if
     it is too small at any point. Z_BUF_ERROR*/
 err = inflate(&stream, Z_FINISH);

 if(err < 0) {
    char *msg =  stream.msg; /*XXX should go away after next command and not be valid when we get to ERROR... but okay for now.*/
    inflateEnd(&stream);
    PROBLEM  "Failed to uncompress the raw data: (%d) %s", err, msg
    ERROR;
 }

 /* terminate our string. */
 len = stream.total_out;
 /* clean up after ourselves. */
 inflateEnd(&stream);

  /* Make the R character string. */
  if(LOGICAL(asText)[0]) {
      ans[stream.total_out]  = '\0';
      r_ans = mkString(ans);
  } else {
      r_ans = allocVector(RAWSXP, stream.total_out);
      memcpy(RAW(r_ans), ans, stream.total_out);
  }
 
 r_ans = mkString(ans);

 return(r_ans);
}


SEXP
R_compress(SEXP r_source, SEXP r_result, SEXP r_level)
{
  char *ans;
  uLongf destLen = 0;
  uLong sourceLen;
  int status;
  const char *source = CHAR(STRING_ELT(r_source, 0));
  SEXP r_ans ;
  unsigned char *result;
  int numProtects = 0;
  int level = -1;

  if(GET_LENGTH(r_level))
      level = INTEGER(r_level)[0];

  sourceLen = strlen(source);
  
 
  destLen = GET_LENGTH(r_result);
  result = RAW(r_result);

  do {
      status = level == -1 ?
                 compress((unsigned char *) result, &destLen, (unsigned char *) source, sourceLen)
                :
                 compress2((unsigned char *) result, &destLen, (unsigned char *) source, sourceLen, level)                  ;
      if(status == Z_OK) 
	  break;
      else if(status == Z_BUF_ERROR) {
	 SET_LENGTH(r_result, 2*destLen);
	 PROTECT(r_result); numProtects++;
	 result = RAW(r_result);
	 destLen *= 2;
      } else if(status == Z_MEM_ERROR) {
	  PROBLEM "run out of memory during compression of (gzip) source"
          ERROR;	  
      }
  } while(1);

  SET_LENGTH(r_result, destLen);

  if(numProtects)
      UNPROTECT(numProtects);

  return(r_result);
}



SEXP
R_gzip(SEXP r_content, SEXP r_level, SEXP r_windowBits, SEXP r_memLevel, SEXP r_strategy,
         SEXP r_result)
{
  char *ans;
  uLongf destLen = 0;

  int status;

  int numProtects = 0;
  int level = -1;

  z_stream strm;
  int method = Z_DEFLATED;
  int windowBits = INTEGER(r_windowBits)[0];
  int memLevel = INTEGER(r_memLevel)[0];
  int strategy = INTEGER(r_strategy)[0];

  const Bytef *dict = NULL;
  uInt dictLength = 0;


  if(GET_LENGTH(r_level))
      level = INTEGER(r_level)[0];


  strm.zalloc = NULL;
  strm.zfree = NULL;
  strm.opaque = NULL;
  strm.total_out = 0;
  strm.next_in = RAW(r_content);
  strm.avail_in = GET_LENGTH(r_content);

  status = deflateInit2(&strm, level, method, windowBits, memLevel, strategy);
  if(status != Z_OK) {
      PROBLEM "can't initialize deflation mechanism for gzip compression"
          ERROR;
  }
/*  deflateSetDictionary(&strm, dict, dictLength); */
  
 
  destLen = GET_LENGTH(r_result);

  do {
      strm.next_out = RAW(r_result) + strm.total_out;
      strm.avail_out = destLen - strm.total_out;

      status = deflate(&strm, Z_FINISH);
      if(status == Z_STREAM_END) 
	  break;
      else if(status == Z_OK) {
	 SET_LENGTH(r_result, 2*destLen);
	 PROTECT(r_result); numProtects++;
	 destLen *= 2;
      } else if(status == Z_MEM_ERROR) {
	  PROBLEM "run out of memory during compression of (gzip) source"
          ERROR;	  
      }
  } while(1);


  SET_LENGTH(r_result, strm.total_out);

  deflateEnd(&strm);

  if(numProtects)
      UNPROTECT(numProtects);

  return(r_result);
}
