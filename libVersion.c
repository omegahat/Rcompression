#include <stdio.h>



#ifdef USE_BZIP2
#define zlibVersion BZ2_bzlibVersion
#include <bzlib.h>
#else
#include <zlib.h>
#endif

int
main(int argc, char *argv[])
{
  const char *ptr = zlibVersion();
  if(argc == 1) {
      printf("%s\n", ptr);
  } else {
     /* get the minor number */
      int major, minor;
      sscanf(ptr, "%d.%d", &major, &minor);
      printf("%d\n", minor);
  }
  return(0);
}
