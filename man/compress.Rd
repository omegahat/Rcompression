\name{compress}
\alias{compress}
\title{In-memory zlib compression of R content}
\description{
  This uses the standard zlib algorithm/format for compressing the input
  into a buffer that can be passed to other computations.

  This does not use the same algorithm or format that the
  shell tool \code{compress} uses, i.e. LZW (Lempel-Ziv-Welch).
}
\usage{
compress(str, size = nchar(str) * 1.01 + 13, level = integer(3))
}
\arguments{
  \item{str}{the text to be compressed}
  \item{size}{the size for a working buffer that zlib uses during the compression.}
  \item{level}{the level of compression. This is a number between 0 and
    9. 9 means highly compressed, 0 means no compression at all.
    The trade-off is computational intensity: the greater the compression,
    the greater the time spent performing the compression.
   }
}
\value{
 A \dQuote{raw} vector containing the compressed  contents.
}
\references{zlib and bzip2}
\author{Duncan Temple Lang}

\seealso{
  \code{\link{uncompress}}
  \code{\link{gunzip}}
  \code{\link{bunzip2}}  
}
\examples{
 x = "A string to compress"
 g = compress(x)
 uncompress(g) == x
}

\keyword{IO}
\keyword{programming}
\concept{compression}
\concept{in-memory}
