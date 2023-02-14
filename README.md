## The Rcompression Package
### Read and write tar, zip, bz2 compressed and archive files and memory






## Installation


This package depends on zlib and bzip2's library.
On most machines, you will be able to use existing
installations of both of these systems.
I have tested this using version 1.2.3 of zlib
and 1.0.3 of bzip2.  You can find these libraries
at 
  http://www.gzip.org/zlib/
and
  http://www.bzip.org/

On one of my older machines, I had difficulty with the version
of zlib


If you pass bzip2 data to gzip or vice verse, who knows what will happen,
but it probably won't be good!  We may add some error checking in the future
but that involves looking at the headers, etc.


gnuwin32.sourceforge.net/packages/bzip2.htm


------------------------------------------------------------------------------
WINDOWS

On Windows, the installation uses the environment variables
LIB_BZIP2 and LIB_ZLIB. Set these to be the fully qualified
names of the directories where you have extracted the relevant
archive. For me, they are set to 

 C:/duncan/bzip2
and
 C:/duncan/zlib

I use the MS-DOS command prompt rather than cygwin,
if the R installation directory ($R_HOME) has a space in it.

