#include <bzlib.h>

#include <Rdefines.h>
#include <Rinternals.h>
#include <R_ext/Memory.h>


/* Allocation and free routines for the z_stream in zlib. */
static void*
R_zlib_alloc(void * ptr, int items, int size)
{
  return(R_alloc(items, size));
}

static void
R_zlib_free(void* ptr, void *addr)
{
 /* R will free things when we are done. */
}


SEXP
R_bz2uncompress(SEXP r_source, SEXP r_guess_size, SEXP r_verbose, SEXP asText)
{
 bz_stream stream;
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

 stream.bzalloc = R_zlib_alloc;
 stream.bzfree = R_zlib_free;
 stream.opaque = NULL;

  /* The MAX_WBITS+16 incantation came from Pascal Scheffers' Tcl bindings for zlib. */
 err = BZ2_bzDecompressInit( &stream, 0, 0); 
 if(err != BZ_OK) {
  PROBLEM  "cannot establish the uncompres/inflate stream on this data (%d)", err
  ERROR;
 }
  /* inflate the entire thing.  XXX Need to put this in a loop where we extend the output buffer size if
     it is too small at any point. Z_BUF_ERROR*/
 while(1) {
     err = BZ2_bzDecompress(&stream);
     if(err == BZ_STREAM_END) 
	 break;
 }

 if(err < 0) {
    char *msg = "<no message yet>"; /*XXX should go away after next command and not be valid when we get to ERROR... but okay for now.*/
    BZ2_bzDecompressEnd(&stream);
    PROBLEM  "Failed to uncompress the raw data: (%d) %s", err, msg
    ERROR;
 }

 len = stream.total_out_lo32;
  /* clean up after ourselves. */
 BZ2_bzDecompressEnd(&stream);

  /* Make the R character string. */
 if(LOGICAL(asText)[0]) {
     /* terminate our string. */
     ans[stream.total_out_lo32]  = '\0'; /*XXX on 64 bit, need to look at the _hi32 field also.*/
     r_ans = mkString(ans);
 } else {
     r_ans = allocVector(RAWSXP, len);
     memcpy(RAW(r_ans), ans, len);
 }


 return(r_ans);
}


SEXP
R_bzlibVersion ()
{
 SEXP ans;
 ans = mkString(BZ2_bzlibVersion());
 return(ans);
}
