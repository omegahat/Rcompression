/*
 * untgz.c -- Display contents and extract files from a gzip'd TAR file
 *
 * written by Pedro A. Aranda Gutierrez <paag@tid.es>
 * adaptation to Unix by Jean-loup Gailly <jloup@gzip.org>
 * various fixes by Cosmin Truta <cosmint@cs.ubbcluj.ro>
 * and adapted for the Rcompression package by Duncan Temple Lang
 *  <duncan@r-project.org>
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#include "untgz.h"

#ifdef error
#undef error
#endif
#define error R_error


char *TGZfname          OF((const char *));
void TGZnotfound        OF((const char *));

int getoct              OF((char *, int));
char *strtime           OF((time_t *));
int setfiletime         OF((char *, time_t));
void push_attr          OF((struct attr_item **, char *, int, time_t));
void restore_attr       OF((struct attr_item **));

int ExprMatch           OF((char *, char *));

int makedir             OF((char *));
int matchname           OF((int, int, char **, char *));

void help               OF((int));
void error              OF((const char *));

char *prog;

const char *TGZsuffix[] = { "\0", ".tar", ".tar.gz", ".taz", ".tgz", NULL };

/* return the file name of the TGZ archive */
/* or NULL if it does not exist */

char *TGZfname (const char *arcname)
{
  static char buffer[1024];
  int origlen,i;

  strcpy(buffer,arcname);
  origlen = strlen(buffer);

  for (i=0; TGZsuffix[i]; i++)
    {
       strcpy(buffer+origlen,TGZsuffix[i]);
       if (access(buffer,F_OK) == 0)
         return buffer;
    }
  return NULL;
}


/* error message for the filename */

void TGZnotfound (const char *arcname)
{
  int i;

  fprintf(stderr,"%s: Couldn't find ",prog);
  for (i=0;TGZsuffix[i];i++)
    fprintf(stderr,(TGZsuffix[i+1]) ? "%s%s, " : "or %s%s\n",
            arcname,
            TGZsuffix[i]);
  exit(1);
}


/* convert octal digits to int */
/* on error return -1 */

int getoct (char *p,int width)
{
  int result = 0;
  char c;

  while (width--)
    {
      c = *p++;
      if (c == 0)
        break;
      if (c == ' ')
        continue;
      if (c < '0' || c > '7')
        return -1;
      result = result * 8 + (c - '0');
    }
  return result;
}


/* convert time_t to string */
/* use the "YYYY/MM/DD hh:mm:ss" format */

char *strtime (time_t *t)
{
  struct tm   *local;
  static char result[32];

  local = localtime(t);
  sprintf(result,"%4d/%02d/%02d %02d:%02d:%02d",
          local->tm_year+1900, local->tm_mon+1, local->tm_mday,
          local->tm_hour, local->tm_min, local->tm_sec);
  return result;
}


/* set file time */

int setfiletime (char *fname,time_t ftime)
{
#ifdef WIN32
  static int isWinNT = -1;
  SYSTEMTIME st;
  FILETIME locft, modft;
  struct tm *loctm;
  HANDLE hFile;
  int result;

  loctm = localtime(&ftime);
  if (loctm == NULL)
    return -1;

  st.wYear         = (WORD)loctm->tm_year + 1900;
  st.wMonth        = (WORD)loctm->tm_mon + 1;
  st.wDayOfWeek    = (WORD)loctm->tm_wday;
  st.wDay          = (WORD)loctm->tm_mday;
  st.wHour         = (WORD)loctm->tm_hour;
  st.wMinute       = (WORD)loctm->tm_min;
  st.wSecond       = (WORD)loctm->tm_sec;
  st.wMilliseconds = 0;
  if (!SystemTimeToFileTime(&st, &locft) ||
      !LocalFileTimeToFileTime(&locft, &modft))
    return -1;

  if (isWinNT < 0)
    isWinNT = (GetVersion() < 0x80000000) ? 1 : 0;
  hFile = CreateFile(fname, GENERIC_WRITE, 0, NULL, OPEN_EXISTING,
                     (isWinNT ? FILE_FLAG_BACKUP_SEMANTICS : 0),
                     NULL);
  if (hFile == INVALID_HANDLE_VALUE)
    return -1;
  result = SetFileTime(hFile, NULL, NULL, &modft) ? 0 : -1;
  CloseHandle(hFile);
  return result;
#else
  struct utimbuf settime;

  settime.actime = settime.modtime = ftime;
  return utime(fname,&settime);
#endif
}


/* push file attributes */

void push_attr(struct attr_item **list,char *fname,int mode,time_t time)
{
  struct attr_item *item;

  item = (struct attr_item *)malloc(sizeof(struct attr_item));
  if (item == NULL)
    error("Out of memory");
  item->fname = strdup(fname);
  item->mode  = mode;
  item->time  = time;
  item->next  = *list;
  *list       = item;
}


/* restore file attributes */

void restore_attr(struct attr_item **list)
{
  struct attr_item *item, *prev;

  for (item = *list; item != NULL; )
    {
      setfiletime(item->fname,item->time);
      chmod(item->fname,item->mode);
      prev = item;
      item = item->next;
      free(prev);
    }
  *list = NULL;
}


/* match regular expression */

#define ISSPECIAL(c) (((c) == '*') || ((c) == '/'))

int ExprMatch (char *string, char *expr)
{
  while (1)
    {
      if (ISSPECIAL(*expr))
        {
          if (*expr == '/')
            {
              if (*string != '\\' && *string != '/')
                return 0;
              string ++; expr++;
            }
          else if (*expr == '*')
            {
              if (*expr ++ == 0)
                return 1;
              while (*++string != *expr)
                if (*string == 0)
                  return 0;
            }
        }
      else
        {
          if (*string != *expr)
            return 0;
          if (*expr++ == 0)
            return 1;
          string++;
        }
    }
}


/* recursive mkdir */
/* abort on ENOENT; ignore other errors like "directory already exists" */
/* return 1 if OK */
/*        0 on error */

int makedir (char *newdir)
{
  char *buffer = strdup(newdir);
  char *p;
  int  len = strlen(buffer);

  if (len <= 0) {
    free(buffer);
    return 0;
  }
  if (buffer[len-1] == '/') {
    buffer[len-1] = '\0';
  }
  if (mkdir(buffer, 0755) == 0)
    {
      free(buffer);
      return 1;
    }

  p = buffer+1;
  while (1)
    {
      char hold;

      while(*p && *p != '\\' && *p != '/')
        p++;
      hold = *p;
      *p = 0;
      if ((mkdir(buffer, 0755) == -1) && (errno == ENOENT))
        {
          fprintf(stderr,"%s: Couldn't create directory %s\n",prog,buffer);
          free(buffer);
          return 0;
        }
      if (hold == 0)
        break;
      *p++ = hold;
    }
  free(buffer);
  return 1;
}


int matchname (int arg,int argc,char **argv,char *fname)
{
  if (arg == 1/*argc */)      /* no arguments given (untgz tgzarchive) */
    return 1;

  arg = 1;
  while (arg < argc)
   if (strcmp(fname, argv[arg++]) == 0)  /* ExprMatch(fname,argv[arg++]) */
      return 1;

  return 0; /* ignore this for the moment being */
}


/* tar file list or extract */


#ifdef ERROR
#undef ERROR
#endif

#include <R_ext/RS.h>

void R_error(const char *msg)
{
  PROBLEM "%s: %s", prog, msg
  ERROR;
}



#include "Rtar.h"
#include <Rdefines.h>

size_t 
gzread_proxy(void *stream, union tar_buffer *buffer, size_t size, DataSource *src)
{
    return(gzread((gzFile) stream, buffer, size));
}

const char *
gzerror_proxy(void *stream, int *errnum, DataSource *src)
{
    return(gzerror((gzFile *) stream, errnum));
}


size_t 
rawRead(void *gstream, union tar_buffer *buffer, size_t size, DataSource *src)
{
    R_rawStream *stream = (R_rawStream *) gstream;
    if(size > stream->pos + stream->len) {
	PROBLEM  "trying to read more bytes than available in raw stream"
	    WARN;
    }
	
    memcpy(buffer,stream->data + stream->pos, size);
    stream->pos += size;
    return(size);
}

const char *
rawError(void *stream, int *errnum, DataSource *src)
{
    return("error reading from raw vector");
}




int tar (gzFile in, int action, int arg, int argc,
         char **argv, TarCallbackFun cb, void *data)
{
    DataSource src;
    src.read = gzread_proxy;
    src.throwError = gzerror_proxy;
    src.data = in;
    return(funTar(&src, action, arg, argc, argv, cb, data));
}


int funTar (DataSource *src, int action, int arg, int argc,
            char **argv, TarCallbackFun cb, void *data)
{
  union  tar_buffer buffer;
  int    len;
  int    err;
  int    getheader = 1;
  int    remaining = 0;
  FILE   *outfile = NULL;
  char   fname[BLOCKSIZE];
  int    tarmode;
  time_t tartime;
  struct attr_item *attributes = NULL;
  int    ctr = 0;
  int extracting = 0;


  while (1)
    {
      ctr++;
      len = src->read(src->data, &buffer, BLOCKSIZE, src);
      if (len < 0)
	  error(src->throwError(src->data, &err, src));
      /*
       * Always expect complete blocks to process
       * the tar information.
       */
      if (len != BLOCKSIZE)
        {
          action = TGZ_INVALID; /* force error exit */
          remaining = 0;        /* force I/O cleanup */
        }

      /*
       * If we have to get a tar header
       */
      if (getheader >= 1)
        {
          /*
           * if we met the end of the tar
           * or the end-of-tar block,
           * we are done
           */
          if (len == 0 || buffer.header.name[0] == 0)
            break;

          tarmode = getoct(buffer.header.mode,8);
          tartime = (time_t)getoct(buffer.header.mtime,12);
          if (tarmode == -1 || tartime == (time_t)-1)
            {
              buffer.header.name[0] = 0;
              action = TGZ_INVALID;
            }

          if (getheader == 1)
            {
              strncpy(fname,buffer.header.name,SHORTNAMESIZE);
   	      extracting = 0;
              if (fname[SHORTNAMESIZE-1] != 0)
                  fname[SHORTNAMESIZE] = 0;
            }
          else
            {
              /*
               * The file name is longer than SHORTNAMESIZE
               */
              if (strncmp(fname,buffer.header.name,SHORTNAMESIZE-1) != 0)
                  error("bad long name");
              getheader = 1;
            }

          /*
           * Act according to the type flag
           */
          switch (buffer.header.typeflag)
            {
            case DIRTYPE:
               if (action == TGZ_LIST) {
                 cb(ctr, DIRTYPE, tartime, fname, remaining, data);
                  /* printf(" %s     <dir> %s\n",strtime(&tartime),fname); */
               }
               else if (action == TGZ_EXTRACT)
                {
		    /* makedir(fname); */
 	   	  extracting = 0;
                  push_attr(&attributes,fname,tarmode,tartime);
                }
              break;
            case REGTYPE:
            case AREGTYPE:
              remaining = getoct(buffer.header.size,12);
              if (remaining == -1)
                {
                  action = TGZ_INVALID;
                  break;
                }
              if (action == TGZ_LIST) {
                  cb(ctr, buffer.header.typeflag, tartime, fname, remaining, data);
                 /* printf(" %s %9d %s\n",strtime(&tartime),remaining,fname); */
              }
              else if (action == TGZ_EXTRACT)
                {
		    extracting = matchname(arg,argc,argv,fname);
                }
              getheader = 0;
              break;
            case GNUTYPE_LONGLINK:
            case GNUTYPE_LONGNAME:
              remaining = getoct(buffer.header.size,12);
              if (remaining < 0 || remaining >= BLOCKSIZE)
                {
                  action = TGZ_INVALID;
                  break;
                }
              len = src->read(src->data, fname, BLOCKSIZE, src);
              if (len < 0)
		  error(src->throwError(src->data, &err, src));
              if (fname[BLOCKSIZE-1] != 0 || (int)strlen(fname) > remaining)
                {
                  action = TGZ_INVALID;
                  break;
                }
              getheader = 2;
              break;
            default:
                if (action == TGZ_LIST) {
                    cb(ctr, '\0', tartime, fname, remaining, data);
                    /* printf(" %s     <---> %s\n",strtime(&tartime),fname); */
                }
              break;
            }
        }
      else
        {
          unsigned int bytes = (remaining > BLOCKSIZE) ? BLOCKSIZE : remaining;

	  if(extracting && action == TGZ_EXTRACT)
	      ((TarExtractCallbackFun ) cb)(fname, buffer.buffer, bytes, remaining, data);
          remaining -= bytes;
        }

      if (remaining == 0)
        {
          getheader = 1;
          if(extracting && action == TGZ_EXTRACT) /* Close this file. */
	      ((TarExtractCallbackFun ) cb)(fname, NULL, 0, remaining, data);
	  if (action != TGZ_INVALID)
                push_attr(&attributes,fname,tarmode,tartime);
        }

      /*
       * Abandon if errors are found
       */
      if (action == TGZ_INVALID)
        {
          error("broken archive");
          break;
        }
    }

  /*
   * Restore file modes and time stamps
   */
  restore_attr(&attributes);

  return 0;
}




#if 0

/* ============================================================ */

void help(int exitval)
{
  printf("untgz version 0.2.1\n"
         "  using zlib version %s\n\n",
         zlibVersion());
  printf("Usage: untgz file.tgz            extract all files\n"
         "       untgz file.tgz fname ...  extract selected files\n"
         "       untgz -l file.tgz         list archive contents\n"
         "       untgz -h                  display this help\n");
  exit(exitval);
}



/* ============================================================ */

#if defined(WIN32) && defined(__GNUC__)
int _CRT_glob = 0;      /* disable argument globbing in MinGW */
#endif


int main(int argc,char **argv)
{
    int         action = TGZ_EXTRACT;
    int         arg = 1;
    char        *TGZfile;
    gzFile      *f;

    prog = strrchr(argv[0],'\\');
    if (prog == NULL)
      {
        prog = strrchr(argv[0],'/');
        if (prog == NULL)
          {
            prog = strrchr(argv[0],':');
            if (prog == NULL)
              prog = argv[0];
            else
              prog++;
          }
        else
          prog++;
      }
    else
      prog++;

    if (argc == 1)
      help(0);

    if (strcmp(argv[arg],"-l") == 0)
      {
        action = TGZ_LIST;
        if (argc == ++arg)
          help(0);
      }
    else if (strcmp(argv[arg],"-h") == 0)
      {
        help(0);
      }

    if ((TGZfile = TGZfname(argv[arg])) == NULL)
      TGZnotfound(argv[arg]);

    ++arg;
    if ((action == TGZ_LIST) && (arg != argc))
      help(1);

/*
 *  Process the TGZ file
 */
    switch(action)
      {
      case TGZ_LIST:
      case TGZ_EXTRACT:
        f = gzopen(TGZfile,"rb");
        if (f == NULL)
          {
            fprintf(stderr,"%s: Couldn't gzopen %s\n",prog,TGZfile);
            return 1;
          }
        exit(tar(f, action, arg, argc, argv));
      break;

      default:
        error("Unknown option");
        exit(1);
      }

    return 0;
}
#endif
