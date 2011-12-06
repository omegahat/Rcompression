#include "miniunzip.h"
#include <stdlib.h>

#include "RConverters.h"

typedef struct {
    long len;
    long offset;
    void *bytes;
    char *filename;
    zlib_filefunc_def *funs;
} InMemoryZipFile;


#define CHECK_OPEN(data)  if(data->offset < 0) { PROBLEM "in-memory zip file is not open" ERROR; }

#define MIN(a, b)  ((a) < (b)) ? (a) : (b)

voidpf
open_raw_zip(voidpf opaque, const char* filename, int mode)
{
    InMemoryZipFile *data = (InMemoryZipFile *) opaque;
    data->offset = 0;
    return(opaque);
}

uLong
read_file_raw_zip(voidpf opaque, voidpf stream, void* buf, uLong size)
{
    InMemoryZipFile *data = (InMemoryZipFile *) opaque;
    uLong num;
    CHECK_OPEN(data);
    if(data->offset + size > data->len) {
        PROBLEM "trying to read too many bytes from zip buffer"
            ERROR;
    }
       
    num = size; /* MIN(size, data->len - data->offset); */
    memcpy(buf, data->bytes + data->offset, num);
    data->offset += num;
    return(num);
}

long
seek_file_raw_zip(voidpf opaque, voidpf stream, uLong offset, int origin)
{
    InMemoryZipFile *data = (InMemoryZipFile *) opaque;
    long ans;

    CHECK_OPEN(data)

    switch(origin)  {
       case ZLIB_FILEFUNC_SEEK_CUR :
	   ans = data->offset + offset;
	   break;
       case ZLIB_FILEFUNC_SEEK_END :
	   ans = data->len - offset;
	   break;
       case ZLIB_FILEFUNC_SEEK_SET :
	   ans = offset;
	   break;
       default: return -1;
    }
    
    data->offset = ans;
#ifdef RCOMPRESSION_DEBUG
fprintf(stderr, "%ld (%d) %s %ld\n", data->offset, origin, origin == ZLIB_FILEFUNC_SEEK_CUR  ? "cur" :
                                                    origin == ZLIB_FILEFUNC_SEEK_END ? "end" : "set" , offset);
#endif
    return(0);
}

int
close_file_raw_zip(voidpf opaque, voidpf stream)
{
    InMemoryZipFile *data = (InMemoryZipFile *) opaque;
    data->offset = -1;
    return(0);
}

int
error_file_raw_zip(voidpf opaque, voidpf stream)
{
    PROBLEM  "error in 'in-memory' zip file actions"
    ERROR;
    return(0); /* never executed */
}

long
tell_file_raw_zip(voidpf opaque, voidpf stream)
{
    InMemoryZipFile *data = (InMemoryZipFile *) opaque;
    CHECK_OPEN(data)
    return(data->offset);
}

SEXP
R_unzOpenRaw(SEXP r_r976, SEXP r_filename)
{
    zlib_filefunc_def *funs;
    unzFile ans;
    InMemoryZipFile *data;

    funs = (zlib_filefunc_def *) calloc(1, sizeof(zlib_filefunc_def));
    if(!funs) {
	PROBLEM "can't allocate space for the function definitions for inline/memory-based zip"
        ERROR;
    }

    data = (InMemoryZipFile *) malloc(sizeof(InMemoryZipFile));
    if(!data) {
	PROBLEM "can't allocate space for in memory zip data container!"
        ERROR;
    }

    if(Rf_length(r_filename))
	data->filename = strdup(CHAR(STRING_ELT(r_filename, 0)));
    else
	data->filename = NULL;
	    
    
    data->offset = -1;
    data->bytes = RAW(r_r976);
    data->len = Rf_length(r_r976);
    data->funs = funs;

    funs->zopen_file = open_raw_zip;
    funs->zread_file = read_file_raw_zip;
    funs->zseek_file = seek_file_raw_zip;
    funs->ztell_file = tell_file_raw_zip;
    funs->zclose_file = close_file_raw_zip;
    funs->zerror_file = error_file_raw_zip;

    funs->opaque = data;
    ans = unzOpen2((const char *) data, funs);

    if(!ans) {
        PROBLEM "failed to 'open' in-memory zip file"
            ERROR;
    }

    ans = R_MAKE_REF_TYPE( (void *)  ans ,  unzMemoryRef);
    PROTECT(ans);
    SET_SLOT(ans, Rf_install("localRData"), R_createNativeReference( (void *)  data ,  "unzInMemoryDataRef", "unzInMemoryDataRef" ));
    UNPROTECT(1);
    return(ans) ;
}


SEXP
R_unzMemoryRef_reset(SEXP r_obj, SEXP r_offset)
{
    unzFile ans;
    InMemoryZipFile *data;
    int off;
    data = DEREF_REF_PTR_CLASS(r_obj, InMemoryZipFile, unzInMemoryData);
    off = INTEGER(r_offset)[0];
    if(off < 0) {
	data->offset = 0;
	unzOpen2((char *) data, data->funs);
    } else
	data->offset = off;

    return(ScalarLogical(TRUE));
}

