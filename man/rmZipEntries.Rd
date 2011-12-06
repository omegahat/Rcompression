\name{rmZipEntries}
\alias{rmZipEntries}
\title{Remove entries from a Zip archive}
\description{
  This function deletes entries within an existing archive.

}
\usage{
rmZipEntries(archive, entries)
}
\arguments{
  \item{archive}{the name of the archive or the \code{ZipArchive} object}
  \item{entries}{the names or indices of the entries to delete}
}
\value{
  An updated version of the \code{archive} object with the
  names of the elements updated.
}
%\references{}
\note{
  This currently is not implemented for in-memory archives.
  We also need to implement a version for \code{RdzArchive} objects
  that updates the .toc entry.
}
\author{
Duncan Temple Lang
}

\seealso{
 \code{\link{zipArchive}}
}
\examples{
 x = I(c(a = "ABC", b = "DEF", c = "GHIJKLML"))
 zip("foo.zip", x, append = FALSE)

 z = zipArchive("foo.zip")
 new.z = rmZipEntries(z, "b")
}
\keyword{IO}
