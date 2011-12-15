\name{zipArchive}
\alias{zipArchive}
%\alias{ZipArchive-class}
\alias{$,ZipArchive-method}
\alias{[,ZipArchive,ANY,missing-method}
\alias{[[,ZipArchive,ANY,missing-method}
\alias{[<-,ZipArchive-method}
\alias{[,ZipArchive,missing,missing-method}
\alias{[,ZipArchive,ANY,missing-method}
\alias{$<-,ZipArchive-method}
\alias{[[<-,ZipArchive,ANY-method}
\alias{length,ZipArchive-method}
\alias{names,ZipArchive-method}
\alias{getZipFileEntry}
\alias{getZipComment}
\title{Constructor for object representing ZIP archive on disk}
\description{
  This is a simple function that takes the name of a file
and labels it with an S3 class so that programmers
can then access information about and contents in 
the ZIP archive.  The purpose of this is function
is to return an object with the appropriate information
so that the external ZIP file/archive can be treated
as a list via \code{$}, \code{[} and \code{[[} operations
and one can add elements via \code{[[<-}.

  By default, this checks the file exists. If one wants
to use this to identify a ZIP file that you will create,
you will want to use \code{check = FALSE}.
 
 The \code{class} parameter allows more specialized
 constructors to use this function to create objects
 with more detailed class information.  Using 
 \code{\link[methods]{setOldClass}} would probably be
 more appropriate.
}
\usage{
zipArchive(filename, check = TRUE,
            class = if(is.raw(filename)) "ZipMemoryArchive" else "ZipFileArchive")
getZipFileEntry(archive, el, password = character(), mode = "character",
                 info = getZipInfo(archive), nullOk = FALSE, last = TRUE)
getZipComment(filename)
}

\arguments{
  \item{filename}{the name of the ZIP file. If this is a character
    string, it is passed to \code{\link{path.expand}}.
    It can also be an object of class \code{\link{ZipArchive-class}} or a
    derived class.
   }
  \item{check}{a logical value indicating whether to raise an error if the file doesn't exist.} 
  \item{class}{a character vector giving the name(s) of the S4 classes
    for the resulting object.}

  \item{archive}{the object of class \code{ZipArchive} or some derived
    class.}  
  \item{el}{the name or index of the element in the Zip archive to
    extract.}
  \item{password}{a character string giving the password to access the
    contents of the archive, if necessary.}
  \item{mode}{currently ignore.}
  \item{info}{the information about the contents of the archive. This is
    used to match the requested element and to navigate to the relevant
    part of the archive. This is typically not specified by the caller.
    For repeated access, it can be useful to compute this once and pass
    it explicitly, avoiding recomputation.}
  \item{nullOk}{a logical value that controls whether a return value of
    \code{NULL} is acceptable or raises an error.}
  \item{last}{a logical value which indicates whether to take last or
    the first element with the specified name (\code{el}) in the case
    that there are multiple entries with the same name. This allows us
    to append new versions of existing entries rather than replacing
    them which is more expensive as we have to rewrite all the elements in
    the archive. When there are multiple elements with the same name,
     this parameter controls whether we get the first or last with code
    of the form \code{ar[["x"]]} and, by default, returns the last one.
   }
}
\value{
 \code{zipArchive} returns A character vector giving the expanded name of the specified file
 with the specified \code{class} vector as the class attribute.

 For the element accessor operators (\code{$}, \code{[} and \code{[[})
 and \code{getZipFileEntry}, the contents of the specified file(s) within the archive are returned.

 For the assignment operators (\code{$<-}, \code{[<-} and \code{[[<-}),
 the updated archive object is returned.
}
\references{
}
\author{Duncan Temple Lang}
\seealso{
 \code{\link{getZipInfo}}
}
\examples{
  f = system.file("sampleData", "MyZip.zip", package = "Rcompression")
  ar = zipArchive(f)
  names(ar)
  length(ar)
  ar[["FAQ.html"]]
  ar[["bunzip"]]  # partial matching
  ar[".*"]  # regular expression


  f = system.file("sampleData", "tests.zip", package = "Rcompression")
  ar = zipArchive(f)
   
  names(ar)
  length(ar)

     # This needs a password to access the contents of any of the file.
     # The password is the string "password" (pretty simple).
  ar[["files.R", password = "password"]]

     # without the password, we'd have an error.
  try(ar[["files.R"]])


    # 
  f = system.file("sampleData", "Empty.docx", package = "Rcompression")
  tgt = paste(tempdir(), "word.docx", sep = .Platform$file.sep)
  file.copy(f, tgt)

  ar = zipArchive(tgt)

  tmp = tempfile()
  cat("This is some text\nin a file", file = tmp)
  ar[["fromFile"]] = tmp

  ar[["fromAsIs"]] = I("Text/that/shouldn't be mistaken for a file")
  ar[["fromText"]] = I("more heuristic text")
  names(ar)


  ar["one"] = tmp

  ar[c("two", "fromAsIs")] = list(tmp, I("Text/that/shouldn't be mistaken for a file"))
  names(ar)



   #### 
    # In memory archives

  contents = loadZip(system.file("sampleData", "Empty.docx", package = "Rcompression"))
  ar = zipArchive(contents)
  names(ar)
  length(ar)

  if(require(RCurl) && url.exists('http://www.ecb.int/stats/eurofxref/eurofxref-hist.zip')) {

     data = getURLContent('http://www.ecb.int/stats/eurofxref/eurofxref-hist.zip?1a1b5dbb25d31898b347736783bd440a')
     ar = zipArchive(data)
     read.csv(textConnection(ar[[1]]), header = TRUE, na.strings = "N/A")
  }


 #########
     # check entries with duplicate names
  content = I(c(myFile = "This is raw text",
                  otherFile = paste(letters, collapse = "\n"),
                  x = "a", x = "b", x = "c"))

  zip("asis.zip", content, append = FALSE)
  z = zipArchive("asis.zip")

  z[["x"]]               # c
  z$x                    # c
  z[["x", last = FALSE]] # a
  z[[4]]                 # b


  # or another view

 zip("bob.zip", list(first = I("Some text"),
                     x = I("number one"),
                     x = I("number 2"),
                     x = I("third one")),  append = FALSE)
 a = zipArchive("bob.zip")

 a[["x"]]  # get the last one
 a[["x", last = FALSE]] # first one
 a[[4]]  # last one again
 a[[3]]  # second x
 a$x  # last one.

}
\keyword{IO}
\keyword{programming}
