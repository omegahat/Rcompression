\name{Rdz}
\alias{Rdz}
\alias{RdzArchive-class}
\alias{[[,RdzArchive,character,missing-method}
\alias{[,RdzArchive,missing,missing-method}
\alias{[,RdzArchive,numeric,missing-method}
\alias{[[,RdzArchive,numeric,missing-method}
\alias{$,RdzArchive-method}
\alias{$<-,RdzArchive-method}
\alias{[[<-,RdzArchive,character-method}
\alias{load,RdzArchive-method}
\title{Constructor for zipped R data archive}
\description{
  This is a constructor function that creates a "reference" to a file
  that represents a zipped archive of individual R objects saved in the
  archive.
  The resulting object can be indexed by name and a table of contents
  can be retrieved to find the names of the variables it contains.

  This function returns an object of class \code{RdzArchive}
  which extends \code{\link{ZipFileArchive-class}} and
  is intended only to provide a mechanism to conver the elements to R objects.
}
\usage{
Rdz(filename, check = TRUE, class = "RdzArchive")
}
\arguments{
  \item{filename}{the name of the file}
  \item{check}{argument passed to \code{\link{zipArchive}} to control
    whether the meta-data about the entries in the zip file is computed.}
  \item{class}{the class of the resulting object, typically unspecified}
}
\value{
An object of class \code{\link{RdzArchive-class}}.
}
\author{
Duncan Temple Lang
}
\seealso{}
\examples{
 x = 1:10
 y = letters
 bob = zave(x, y, mtcars, other = x, file = "/tmp/bob.zip", bob = 1:10, zz = 2 * log(1:100), oo = rnorm(10))
 names(bob)
 bob$.toc
 bob[["y"]]
 bob$oo
}
\keyword{IO}
