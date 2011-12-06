\name{gzip}
\alias{gzip}
\title{Perform in-memory gzip compression}
\description{
This function compresses the content  using the GZIP compression
format and returns the resulting compressed content. 
It does this within memory rather than writing to file.
This content can then be passed to other functions to be
used in other contexts, e.g. sent to a Web server as part of a request,
inserted into an HTML document via base64 encoding.
}
\usage{
gzip(content, level = 1, windowBits = (15 + 16), memLevel = 9, strategy = 0L, 
      size = length(content) * 1.01 + 12)
}
\arguments{
  \item{content}{the content to be compressed. This should be either a \code{raw} vector
  or a character vector which will be collapsed to a single string.
}
  \item{level}{the compression level, a number between 1 and 9}
  \item{windowBits}{integer between 24 and 31. Larger values result in better compression at the expense of memory usage.
  This is a value between 8 and 15 with 16 added on to cause GZIP compression to be used. }
  \item{memLevel}{a value between 1 and 9 that controls the tradeoff of memory and speed  used in the 
   process of compression. Larger values use more memory with better speed.}
  \item{strategy}{an integer, this should be 0 for the default strategy.
     filter, huffman and rle strategies are also available.}
  \item{size}{a number, the size to use as the best guess for the size of the result.
   The output buffer will grow as necessary, but this provides an opportunity to 
    specify an initial guees.
   }
}
\details{
This uses the zlib library.
}
\value{
 A \code{raw} object containing the compressed information.
Note that this cannot currently be uncompressed with the
\code{\link{gunzip}} function but can be decompressed with
the gzip application.
}
\references{
\url{http://www.gzip.org}
}
\author{
Duncan Temple Lang
}
\note{
}

\seealso{
\code{\link{compress}}
}
\examples{
txt = paste(rep("This is a string", 40), collapse = "\n")
v = gzip(txt)
f = tempfile()
writeBin(v, f)
readLines(gzfile(f))


dev = paste(tempfile(), "pdf", sep = ".")
pdf(dev)
plot(1:10)
dev.off()
vals = readBinaryFile(dev)
writeBin(gzip(vals), paste(dev, "gz", sep = "."))

}
\keyword{IO}

