\name{uncompress}
\alias{uncompress}
\alias{bunzip2}
\alias{gunzip}
\title{Uncompress in-memory data in either zlib or GNU zip format}
\description{
  These functions take a \dQuote{raw} vector in R that contains
  data that is compressed via some algorithm and attempts to
  inflate/uncompress the data so it can be processed directly with other
  tools.  These function support the basic zlib algorithm, GNU zip
  format  and bunzip2-style compression.
  The difference between these and functions such as
  \code{\link[base]{gzcon}} is that these work with data already in memory,
  not in files.  These are also currently not connections.
}
\usage{
uncompress(content, size = length(content) * 10, asText = TRUE,
            resizeBy = 2)
gunzip(content, size = length(content) * 5, asText = TRUE)
bunzip2(content, size = length(content) * 5, verbose = 0, asText = TRUE)
}
\arguments{
  \item{content}{the \dQuote{raw} vector in R that contains the entire
    stream of compressed data.}
  \item{size}{a value that guesses how big the resulting inflated
    contents will be. This is used to create a buffer that will hold the
    results.  If this is not sufficiently large, the buffer will be
    expanded so it is not vital that this be correct. However, getting
    it about right and a little bigger than the actual resulting size of
    the inflated content will make the processing faster and not waste
    excess memory.
  }
  \item{verbose}{an integer between 0 and 4 inclusive with larger values
    indicating to display more information on the console about the inflation process
    as it is being performed. 0 means no information. }
  \item{asText}{a logical value indicating whether to return the result
    as a simple R string (\code{TRUE}) or leave it uninterpreted as a
    \code{raw} vector.  \code{FALSE} is appropriate if the uncompressed
    contents are binary data.}
  \item{resizeBy}{the factor by which the internal memory buffer used to
    store the uncompressed data is grown when more memory is needed.
    The default is to double the size. In the worst case, this might
    mean needing one more byte to complete the de-compression,
    but asking for \code{2 * (total_length - 1)}.
    This parameter allows the caller to provide  a way to control
    this expansion with contextual knowledge.
    }
}
\value{
 The inflated contents either as a string or a raw vector.
}
\references{zlib and bzip2}
\author{Duncan Temple Lang}

\seealso{
 \code{\link{compress}}
}
\examples{

 x = "A string to compress"
 g = compress(x)
 uncompress(g) == x

 # Read contents of a GNU zipped file and uncompress the contents
 # directly from memory.  We could do this with gz() directly from R
 # but this is just arranging to get the raw data locally rather than,
 # e.g. from an HTTP request

 f = system.file("sampleData", "NAMESPACE.gz", package = "Rcompression")
 con = file(f, "rb")
 fs = file.info(f)$size
 content  = readBin(con, raw(fs), fs)
 close(con)
 gunzip(content, 10000)

}
\keyword{IO}
\keyword{programming}
\concept{compression}
\concept{in-memory}
