\name{tarListCallback}
\alias{tarListCallback}
\title{Callback function to gather information about entries in a
  gzipped tar file.}
\description{
  This is a function that returns two functions
  that can be used in a call to \code{\link{tarInfo}}
  to collect the information about each entry
  in a gzipped tar archive.
  The first function  is called for each entry
  and combines the information for it with previously
  processed entries.
  The second function converts the data into
  a data frame, transforming time information into
  POSIXct values and mapping internal type identifiers
  for the entries into human-readable types,
  e.g. DIRTYPE, REGTYPE, ...
}
\usage{
tarListCallback()
}
%- maybe also 'usage' for other objects documented here.
\arguments{
}
\details{
}
\value{
 A list of two functions
  \item{callback}{the function that is to be invoked for each entry as
    it is encountered}
  \item{.ans}{the function to retrieve the answer.
    This can be return the data as a simple list if
    it is called with the argument \code{FALSE}}
  The list of functions is given a class
  TarInfoCallback to identify it as being a pair
  that \code{\link{tarInfo}} can use together.
}
\references{}
\author{Duncan Temple Lang}

\seealso{
\code{\link{tarInfo}}
}
\examples{
  filename = system.file("sampleData", "OmegahatXSL_0.2-0.tar.gz", package = "Rcompression")
  f = tarListCallback()
  invisible(tarInfo(filename, f$callback))
  f$.ans()
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{IO}

