
%.c.tu: %.c Makefile.tu
	/usr/bin/g++ -I/home6/duncan/Projects/R-2-4/include -I/home6/duncan/Projects/R-2-4/include -I/home/duncan/zlib-1.2.3 -I/home/duncan/bzip2-1.0.3 -I/usr/local/include    -fpic  -g -Wall -pedantic -DUSE_TYPE_CHECKING_STRICT=1 -g  -fdump-translation-unit  -c $< -o /dev/null
