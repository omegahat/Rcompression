/*
 * untgz.c -- Display contents and extract files from a gzip'd TAR file
 *
 * written by Pedro A. Aranda Gutierrez <paag@tid.es>
 * adaptation to Unix by Jean-loup Gailly <jloup@gzip.org>
 * various fixes by Cosmin Truta <cosmint@cs.ubbcluj.ro>
 * and adapted for the Rcompression package by Duncan Temple Lang
 *  <duncan@r-project.org>
 */


#include <time.h>
#include <errno.h>
#include <sys/stat.h>

#include "zlib.h"

#ifdef unix
#  include <unistd.h>
#elif defined WIN32
#  include <direct.h>
#  include <io.h>
#else
#  include <unistd.h>
#endif

#ifdef WIN32
#include <windows.h>
#  ifndef F_OK
#    define F_OK  0
#  endif
#  define mkdir(dirname,mode)   _mkdir(dirname)
#  ifdef _MSC_VER
#    define access(path,mode)   _access(path,mode)
#    define chmod(path,mode)    _chmod(path,mode)
#    define strdup(str)         _strdup(str)
#  endif
#else
#  include <utime.h>
#endif


/* values used in typeflag field */
#if 0
enum {REGTYPE, AREGTYPE, LNKTYPE, SYMTYPE, CHRTYPE, BLKTYPE, DIRTYPE, FIFOTYPE, CONTTYPE,
      GNUTYPE_DUMPDIR, GNUTYPE_LONGLINK, GNUTYPE_LONGNAME, GNUTYPE_MULTIVOL, GNUTYPE_NAMES,
      GNUTYPE_SPARSE, GNUTYPE_VOLHDR
     };

const char *TypeNames[] = {
  "REGTYPE", "AREGTYPE", "LNKTYPE", "SYMTYPE", "CHRTYPE", "BLKTYPE", "DIRTYPE", "FIFOTYPE", "CONTTYPE",
  "GNUTYPE_DUMPDIR", "GNUTYPE_LONGLINK", "GNUTYPE_LONGNAME", "GNUTYPE_MULTIVOL", "GNUTYPE_NAMES",
  "GNUTYPE_SPARSE", "GNUTYPE_VOLHDR"
};

#else

#define REGTYPE  '0'            /* regular file */
#define AREGTYPE '\0'            /* regular file */
#define LNKTYPE  '1'            /* link */
#define SYMTYPE  '2'            /* reserved */
#define CHRTYPE  '3'            /* character special */
#define BLKTYPE  '4'            /* block special */
#define DIRTYPE  '5'            /* directory */
#define FIFOTYPE '6'            /* FIFO special */
#define CONTTYPE '7'            /* reserved */


/* GNU tar extensions */

#define GNUTYPE_DUMPDIR  'D'    /* file names from dumped directory */
#define GNUTYPE_LONGLINK 'K'    /* long link name */
#define GNUTYPE_LONGNAME 'L'    /* long file name */
#define GNUTYPE_MULTIVOL 'M'    /* continuation of file from another volume */
#define GNUTYPE_NAMES    'N'    /* file name that does not fit into main hdr */
#define GNUTYPE_SPARSE   'S'    /* sparse file */
#define GNUTYPE_VOLHDR   'V'    /* tape/volume header */



#ifdef R_UNTGZ
const char TypeValues[] =
       {
        REGTYPE, AREGTYPE, LNKTYPE, SYMTYPE, CHRTYPE, BLKTYPE, DIRTYPE, FIFOTYPE, CONTTYPE,
	GNUTYPE_DUMPDIR, GNUTYPE_LONGLINK, GNUTYPE_LONGNAME, GNUTYPE_MULTIVOL, GNUTYPE_NAMES,
	GNUTYPE_SPARSE, GNUTYPE_VOLHDR
       };

const char *TypeNames[] = {
  "REGTYPE", "AREGTYPE", "LNKTYPE", "SYMTYPE", "CHRTYPE", "BLKTYPE", "DIRTYPE", "FIFOTYPE", "CONTTYPE",
  "GNUTYPE_DUMPDIR", "GNUTYPE_LONGLINK", "GNUTYPE_LONGNAME", "GNUTYPE_MULTIVOL", "GNUTYPE_NAMES",
  "GNUTYPE_SPARSE", "GNUTYPE_VOLHDR"
};
#endif


#endif /* #if 0 */

/* tar header */

#define BLOCKSIZE     512
#define SHORTNAMESIZE 100

struct tar_header
{                               /* byte offset */
  char name[100];               /*   0 */
  char mode[8];                 /* 100 */
  char uid[8];                  /* 108 */
  char gid[8];                  /* 116 */
  char size[12];                /* 124 */
  char mtime[12];               /* 136 */
  char chksum[8];               /* 148 */
  char typeflag;                /* 156 */
  char linkname[100];           /* 157 */
  char magic[6];                /* 257 */
  char version[2];              /* 263 */
  char uname[32];               /* 265 */
  char gname[32];               /* 297 */
  char devmajor[8];             /* 329 */
  char devminor[8];             /* 337 */
  char prefix[155];             /* 345 */
                                /* 500 */
};

union tar_buffer
{
  char               buffer[BLOCKSIZE];
  struct tar_header  header;
};

struct attr_item
{
  struct attr_item  *next;
  char              *fname;
  int                mode;
  time_t             time;
};

enum { TGZ_EXTRACT, TGZ_LIST, TGZ_INVALID };

typedef void (*TarCallbackFun)(int counter, char typeflag, time_t time, const char *fname, int remaining, void *data);
typedef void (*TarExtractCallbackFun)(const char *filename, char *bytes, unsigned int numBytes, unsigned int remaining, void *data);

typedef void(*MatchFileFun)();

int tar                 OF((gzFile, int, int, int, char **, TarCallbackFun cb, void *data));



