#include "minizip.h"


#include <Rdefines.h>
#include <Rinternals.h>
#include "Rcompression.h"

#ifndef WIN32
# include <unistd.h>
# include <utime.h>
# include <sys/types.h>
# include <sys/stat.h>
#include <time.h>
#else
# include <direct.h>
# include <io.h>
#endif

//#include "zip.h"

#ifdef WIN32
/* #define USEWIN32IOAPI */
#include "iowin32.h"
#endif





#ifndef WRITEBUFFERSIZE
#define WRITEBUFFERSIZE (16384)
#endif

#define MAXFILENAME (256)

#ifdef WIN32
uLong filetime(f, tmzip, dt)
    const char *f;                /* name of file to get info on */
    tm_zip *tmzip;             /* return value: access, modific. and creation times */
    uLong *dt;             /* dostime */
{
  int ret = 0;
  {
      FILETIME ftLocal;
      HANDLE hFind;
      WIN32_FIND_DATA  ff32;

      hFind = FindFirstFile(f,&ff32);
      if (hFind != INVALID_HANDLE_VALUE)
      {
        FileTimeToLocalFileTime(&(ff32.ftLastWriteTime),&ftLocal);
        FileTimeToDosDateTime(&ftLocal,((LPWORD)dt)+1,((LPWORD)dt)+0);
        FindClose(hFind);
        ret = 1;
      }
  }
  return ret;
}
#else
#ifdef unix
uLong filetime(f, tmzip, dt)
    char *f;               /* name of file to get info on */
    tm_zip *tmzip;         /* return value: access, modific. and creation times */
    uLong *dt;             /* dostime */
{
  int ret=0;
  struct stat s;        /* results of stat() */
  struct tm* filedate;
  time_t tm_t=0;

  if (strcmp(f,"-")!=0)
  {
    char name[MAXFILENAME+1];
    int len = strlen(f);
    if (len > MAXFILENAME)
      len = MAXFILENAME;

    strncpy(name, f,MAXFILENAME-1);
    /* strncpy doesnt append the trailing NULL, of the string is too long. */
    name[ MAXFILENAME ] = '\0';

    if (name[len - 1] == '/')
      name[len - 1] = '\0';
    /* not all systems allow stat'ing a file with / appended */
    if (stat(name,&s)==0)
    {
      tm_t = s.st_mtime;
      ret = 1;
    }
  }
  filedate = localtime(&tm_t);

  tmzip->tm_sec  = filedate->tm_sec;
  tmzip->tm_min  = filedate->tm_min;
  tmzip->tm_hour = filedate->tm_hour;
  tmzip->tm_mday = filedate->tm_mday;
  tmzip->tm_mon  = filedate->tm_mon ;
  tmzip->tm_year = filedate->tm_year;

  return ret;
}
#else
uLong filetime(f, tmzip, dt)
    char *f;                /* name of file to get info on */
    tm_zip *tmzip;             /* return value: access, modific. and creation times */
    uLong *dt;             /* dostime */
{
    return 0;
}
#endif
#endif



/* calculate the CRC32 of a file,
   because to encrypt a file, we need known the CRC32 of the file before */
int getFileCrc(const char* filenameinzip,void*buf,unsigned long size_buf,unsigned long* result_crc)
{
   unsigned long calculate_crc=0;
   int err=ZIP_OK;
   FILE * fin = fopen(filenameinzip,"rb");
   unsigned long size_read = 0;
   unsigned long total_read = 0;
   if (fin==NULL)
   {
       err = ZIP_ERRNO;
   }

    if (err == ZIP_OK)
        do
        {
            err = ZIP_OK;
            size_read = (int)fread(buf,1,size_buf,fin);
            if (size_read < size_buf)
                if (feof(fin)==0)
            {
                printf("error in reading %s\n",filenameinzip);
                err = ZIP_ERRNO;
            }

            if (size_read>0)
                calculate_crc = crc32(calculate_crc,buf,size_read);
            total_read += size_read;

        } while ((err == ZIP_OK) && (size_read>0));

    if (fin)
        fclose(fin);

    *result_crc=calculate_crc;
#if 0
    printf("file %s crc %x\n",filenameinzip,calculate_crc);
#endif
    return err;
}



typedef enum {
    FILENAME = 0,
    AS_IS = 1,
    RAW_CONTENT = 2,
} ContentType;

SEXP
R_createZip(SEXP filename, SEXP filenames, SEXP altNames, 
            SEXP r_compression_level, SEXP append, SEXP typeCode,
            SEXP time, SEXP comments, SEXP globalComment)
{
    zipFile zf;
    int opt_compress_level = INTEGER(r_compression_level)[0];
    int errclose;
    const char *password = NULL;
    const char *filename_try = CHAR(STRING_ELT(filename, 0));
    int opt_overwrite = 0;
    int err, i, numFiles = Rf_length(filenames);

    int size_buf = 0;
    void* buf=NULL;

    SEXP ans = ScalarLogical(TRUE);
    const char *gcomment = NULL;

    opt_overwrite = LOGICAL(append)[0] ? 2 : 0;  /* 2 I believe means append.*/

    size_buf = WRITEBUFFERSIZE;
    buf = (void*) R_alloc(size_buf, 1);

    if(Rf_length(globalComment))
	gcomment = CHAR(STRING_ELT(globalComment, 0));


#        ifdef USEWIN32IOAPI
        zlib_filefunc_def ffunc;
        fill_win32_filefunc(&ffunc);
        zf = zipOpen2(filename_try,(opt_overwrite==2) ? 2 : 0,NULL,&ffunc);
#        else
/*        zf = zipOpen(filename_try,(opt_overwrite==2) ? 2 : 0); */
        zf = zipOpen2(filename_try, (opt_overwrite==2) ? 2 : 0, NULL, NULL);
#        endif

        if (zf == NULL)
        {
            PROBLEM "error opening %s\n",filename_try
   	     ERROR;
            err= ZIP_ERRNO;
        }

        for (i = 0 ; i < numFiles; i++)
        {
            FILE * fin = NULL;
            int size_read;
            const char* filenameinzip;
            zip_fileinfo zi;
            unsigned long crcFile=0;
	    const char *altName;
	    SEXP el;
	    ContentType type = INTEGER(typeCode)[i];
	    const char *comment = NULL;

	    altName = CHAR(STRING_ELT(altNames, i));
	    el = VECTOR_ELT(filenames, i);

	    if(Rf_length(comments))
		comment = CHAR(STRING_ELT(comments, i));

	    if(type != FILENAME)
		filenameinzip = altName;
            else 
                filenameinzip = CHAR(STRING_ELT(el, 0));


                zi.tmz_date.tm_sec = zi.tmz_date.tm_min = zi.tmz_date.tm_hour =
		    zi.tmz_date.tm_mday = zi.tmz_date.tm_mon = 0;
                zi.tmz_date.tm_year = 0;
                zi.dosDate = 0;
                zi.internal_fa = 0;
                zi.external_fa = 0;
		if(type == FILENAME) 
                    filetime(filenameinzip, &zi.tmz_date,&zi.dosDate);
		else {
		    /* Put the current time on these anonymous objects. */
                    int off = i;
		    zi.tmz_date.tm_sec = REAL(VECTOR_ELT(time, 0))[off];
		    zi.tmz_date.tm_min = INTEGER(VECTOR_ELT(time, 1))[off];
		    zi.tmz_date.tm_hour = INTEGER(VECTOR_ELT(time, 2))[off];
		    zi.tmz_date.tm_mday = INTEGER(VECTOR_ELT(time, 3))[off];
		    zi.tmz_date.tm_mon = INTEGER(VECTOR_ELT(time, 4))[off];
		    zi.tmz_date.tm_year = INTEGER(VECTOR_ELT(time, 5))[off];
		}

		
		if (type == FILENAME && (password != NULL) && (err==ZIP_OK))
                    err = getFileCrc(filenameinzip, buf, size_buf, &crcFile);

                err = zipOpenNewFileInZip3(zf, altName /*filenameinzip*/, &zi,
                                 NULL, 0, NULL, 0, comment,
                                 (opt_compress_level != 0) ? Z_DEFLATED : 0,
                                 opt_compress_level,0,
                                 /* -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY, */
                                 -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
                                 password,crcFile);

                if (err != ZIP_OK) {
                    PROBLEM "error in opening %s in zipfile", filenameinzip
			ERROR;
		}
                else {
		    if(type == FILENAME) {
			fin = fopen(filenameinzip, "rb");
			if (fin==NULL) {
			    err=ZIP_ERRNO;
			    PROBLEM "error in opening %s for reading\n",filenameinzip
				ERROR;
			}
		    } else 
			err = ZIP_OK;
		}

                if (err == ZIP_OK) {
	          if(type == FILENAME) {
                    do
                    {
                        err = ZIP_OK;
                        size_read = (int) fread(buf,1,size_buf,fin);
                        if (size_read < size_buf) {
                            if (feof(fin)==0) {
                               PROBLEM "error in reading %s\n",filenameinzip
	  			  ERROR;
			    }
			}

                        if (size_read > 0)
                        {
                            err = zipWriteInFileInZip (zf,buf,size_read);
                            if (err<0)
                            {
                               PROBLEM "error in writing %s in the zipfile\n",
                                                 filenameinzip
				   ERROR;
                            }

                        }
                    } while ((err == ZIP_OK) && (size_read>0));
		  } else {
		      void *tmpBuf;
		      size_t len;
		      if(TYPEOF(el) == RAWSXP) {
			  tmpBuf = RAW(el);
			  len = Rf_length(el);
		      } else {
			  tmpBuf = (void *) CHAR(STRING_ELT(el, 0));
			  len = strlen(tmpBuf);
		      }
		      zipWriteInFileInZip (zf, tmpBuf, len);
		  }
	      }

                if (fin)
                    fclose(fin);

                if (err<0)
                    err=ZIP_ERRNO;
                else
                {
                    err = zipCloseFileInZip(zf);
                    if (err!=ZIP_OK)
                        PROBLEM "error in closing %s in the zipfile\n",
                                    filenameinzip
			    ERROR;
                }
	}

        errclose = zipClose(zf, gcomment);
        if (errclose != ZIP_OK) {
            PROBLEM  "error in closing %s", filename_try
            ERROR;
	}

    return(ans);
}
