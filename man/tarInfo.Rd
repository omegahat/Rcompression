\name{tarInfo}
\alias{tarInfo}
\title{Get table of contents of a gzipped tar file}
\description{
  This function reads a gzipped tar file and,
  by default, returns information about each
  entry in the archive.
  As the archive is being read, when an entry
  is encountered a callback function (in R) or (C) routine 
  is invoked giving details about the entry.
  One can pass an R function to be invoked
  or the address of a C routine.
  The R function should accept arguments
  giving the name of the file (character string),
  entryType (character string),
  the time stamp on the entry (number of seconds from Jan 1, 1970
  00:00), and the size.
  The last argument is a  counter and should be ignored.
  It will be removed.
  
  
}
\usage{
tarInfo(filename, fun = tarListCallback(), data = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{filename}{the name of the gzipped tar file }
  \item{fun}{a function that is invoked for each entry in the archive as
    it is encountered with the entry name, type, time stamp and size.
    This can also be a list of functions with class
    \code{TarInfoCallback}
    with elements named \code{callback} and \code{.ans}.
    One can also provide a native (C) routine to be invoked
    using \code{getNativeSymbolInfo(sym_name)$addres}.
  }
  \item{data}{an object that is passed to a a native routine
    passed via \code{fun}. If that argument is not a routine,
   then this is ignored.}
}
\details{
}
\value{
  By default, the result is a data frame
  with a row for each entry in the archive
  and with columns file, type, timestamp and size.
  If one specifies a value for \code{fun},
  the return value is \code{fun}
  itself in the expectation that one can use
  that to get the result.
  
}
\references{
zlib/contrib/untgz in the zlib-1.2.3 distribution.
}
\author{
  Duncan Temple Lang
  using code in contrib/untgz/
  from the zlib-1.2.3 distribution
  that was writtent by
   Pedro A. Aranda Gutierrez <paag@tid.es>,
   adapted to Unix by Jean-loup Gailly <jloup@gzip.org>
   and with  various fixes by Cosmin Truta <cosmint@cs.ubbcluj.ro>.
}
\note{}
\seealso{
 \code{\link{tarExtract}}
}
\examples{
  filename = system.file("sampleData", "OmegahatXSL_0.2-0.tar.gz", package = "Rcompression")
  tarInfo(filename)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{IO}

