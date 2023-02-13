AC_INIT(DESCRIPTION)

echo "Checking configuration for Rcompression to find libz and libbz2"

AC_PATH_PROG(PKG_CONFIG, pkg-config)

#XX Use R's value of CC
AC_PROG_CC

dnl This is a half-hearted start to finding zlib and bzip2 and checking 
dnl things are okay.

AC_CHECK_HEADER(zlib.h)

ZLIB_CFLAGS=`${PKG_CONFIG} --cflags zlib`
ZLIB_LIBS=`${PKG_CONFIG} --libs zlib`

CCFLAGS="$CCFLAGS $ZLIB_CFLAGS"
AC_SUBST(ZLIB_CFLAGS)
AC_SUBST(ZLIB_LIBS)

BZ2LIB_CFLAGS=""
BZ2LIB_LIBS="-lbz2"

AC_SUBST(BZ2LIB_CFLAGS)
AC_SUBST(BZ2LIB_LIBS)

AC_CHECK_LIB(z, zlibVersion, , [echo "Need help find the zlib library, libz" ; exit 1])


if test -n "${BZIP2_DIR}" ; then
  BZ2LIB_INCLUDE_DIR=$BZIP2_DIR
  BZ2LIB_LIBS_DIR=$BZIP2_DIR
  BZ2LIB_CFLAGS=-I$BZ2LIB_INCLUDE
  BZ2LIB_LIBS=-L$BZ2LIB_LIBS_DIR
else
  AC_CHECK_HEADER(bzlib.h)
  AC_CHECK_LIB(bz2, BZ2_bzlibVersion, ,
                  [ echo "PROBLEM"; echo "Cannot find libbz2.a or .so."; 
                    echo "Download and build it and specify the location of the source using the environment variable BZIP2_DIR"; exit 1])
fi

# We have a piece of C code that will give us the version information.

$CC $CCFLAGS -o zlibVersion  libVersion.c $ZLIB_LIBS
ZLIB_VERSION=`./zlibVersion`
ZLIB_VERSION_MINOR=`./zlibVersion minor`

$CC $CCFLAGS -o bzlibVersion  -DUSE_BZIP2 libVersion.c  -I$BZ2LIB_INCLUDE_DIR  -L$BZ2LIB_LIBS_DIR -lbz2
BZLIB_VERSION=`./bzlibVersion`

echo ""
echo "Version information for libz and bzlib"
echo "   libz $ZLIB_VERSION"
echo "   bzlib $BZLIB_VERSION"
echo ""

if test $ZLIB_VERSION_MINOR -lt 2 ; then
 echo ""
 echo ""
 echo "You might need a more recent version of zlib, i.e. 1.2.*"
 echo "On some machines, this version has caused the gunzip() function to give errors such as"
 echo "     cannot establish the uncompres/inflate stream on this data (-2)"
 echo "If you see this, try install version 1.2.3 or higher"
 echo ""
 echo ""
fi

AC_CONFIG_FILES(src/Makevars)

AC_OUTPUT()
