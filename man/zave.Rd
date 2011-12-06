\name{zave}
\alias{zave}
\title{Serialize one or more R objects to a zip archive}
\description{
 This is an alternative to the \code{\link[base]{save}} function in R
 that saves a collection of R variables to a single archive file
 but maintains them in seperate "files" within the archive
 and allows them to be restored as a group or individually.
 Additionally, one can readily determine the names of the variables
 in the archive using \code{names}.  There is an optional table of contents
 that allows us to determine the class and size of each object.

 This format can be extended to know how to "jump" directly to a variable and
 so provide quick access to individual elements.
}
\usage{
zave(..., list = character(), file = stop("Must specify file name"), 
      envir = parent.frame(), compression_level = 9, .addToc = TRUE, 
       append = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{\dots}{the objects to be serialized, specified by expression or variable name.
     These values can also be given as \code{name = val} and the name is used as the name in the
     resulting archive}
  \item{list}{like \code{\link[base]{save}}, this is a way of specifying the variables to serialize
    by explicit variable name.}
  \item{file}{the name of the file to create or append to}
  \item{envir}{where to find the variables specified by name via \code{list}.}
  \item{compression_level}{the level of compression to use for the zip file. See \code{\link{zip}}.}
  \item{.addToc}{a logical value indicating whether to compute and add a table of contents data frame to the 
    archive. This is a data frame containing the class and object size of the elements.}
   \item{append}{a logical value passed to \code{\link{zip}}}
}
\value{
 An object of class \code{\link{RdzArchive-class}} or an error.
}
\author{
Duncan Temple Lang
}


\seealso{
 \code{\link{load}}
 \code{\link{zip}}
 \code{\link[base]{serialize}}
 \code{\link[base]{save}}
}
\examples{
 x = 1:10
 y = letters
 bob = zave(x, y, mtcars, other = x, file = "/tmp/bob.zip", bobo = 1:10, zz = 2 * log(1:100), oo = rnorm(10))
 names(bob)
 bob$.toc
 bob[["y"]]
 bob$oo
 bob[]
 load(bob)  # put them into the global environment


  # Appending to a previously created Rdz file.
 a = zave(mtcars, file = "bob.Rdz", append = FALSE)
 a$x = 1:10


  # Dealing with duplicates
  # Now that we have replace = TRUE, a$x replaces the existing x by default.
 a = zave(mtcars, file = "bob.Rdz", append = FALSE)
 a[["x"]] = 1:10
 a[["x", replace = FALSE]] = letters
 a[["x", replace = FALSE]] = 20

 a[["x"]]
 a[["x", last = FALSE]] # first x
 a[[4]]  # 2nd x, index includes .toc


 a = zave(list = list(mtcars = mtcars, x = 1:10, x = letters, x = 20),  file = "bob.Rdz", append = FALSE)
 a[["x"]]
 a[["x", last = FALSE]]
 a[[4]]  # 2nd x, index includes .toc
}
\keyword{IO}

