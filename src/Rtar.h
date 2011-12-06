typedef struct _DataSource DataSource;

typedef size_t (*ReadData)(void *stream, union tar_buffer *buffer, size_t size, DataSource *src);
typedef const char * (*ReadError)(void *stream, int *errnum, DataSource *src);

struct _DataSource {
    ReadData read;
    ReadError throwError;
    void *data;
};

int funTar (DataSource *src, int action, int arg, int argc,
	    char **argv, TarCallbackFun cb, void *data);

#include <Rinternals.h>

typedef struct {
    Rbyte *data;
    int len;
    int pos;
} R_rawStream;

size_t  rawRead(void *gstream, union tar_buffer *buffer, size_t size, DataSource *src);
const char *rawError(void *stream, int *errnum, DataSource *src);
