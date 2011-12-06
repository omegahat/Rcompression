\name{zip}
\alias{zip}
\alias{simpleZip}
\title{Create zip archive directly in R}
\description{
 This is currently a mechanism to create a zip archive
 file and insert one or more files or in-memory content into it.
 This works with C code rather than relying on an external
 executable/program. 

 One specifies a list or vector of elements to add to the file along
 with the name of the file to create.  The elements to be added
 can be file names (regular character strings) or AsIs elements
 (created with \code{I()}) or raw vectors containing binary content.
 
 Each element is added to the archive using a name coming from
 the name of the vector/list of elements or \code{altNames}.
 This allows us to give the elements names in the archive that differ
 from the names of files or objects.

 In the  future, I will add facilities to create this  in richer
 ways and to add, replace and remove entries in the archive directly.
}
\usage{
zip(zipfile, files = NULL, append = file.exists(zipfile),
     compression_level = 9, altNames = names(files), time = Sys.time(),
      comments = character(), globalComment = character())
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{zipfile}{the name of the new file to create}
  \item{files}{a character vector giving the names of the files to be added.
   These are the full paths to  files  on the file system.
   One can provide alternative names for the entries in the zip archive via 
   the names of this vector or explicitly via \code{altNames}.

   In the future, we will allow this to be a list and the elements can be file names,
  character strings containing the content,
  \code{raw} vectors containing the binary content, or connections.  The latter is not essential as the caller can 
  read the content from the connection ahead of time. For large files, it is convenient to read from the connection.}
 \item{append}{a logical value indicating whether to append to \code{zipfile} if it already exists,
   or to overwrite it with a new zip file.}
  \item{compression_level}{an integer between 1 and 9 indicating the compression level, with higher
  values meaning higher compression}
  \item{altNames}{a character vector with as many elements as there are elements in
  \code{files}. These names are used as the names of the corresponding elements in the
  zip archive. This allows us to use different  names in the zip archive from those on
  the local file system.}
 \item{time}{a vector of POSIXct times specifying the "creation" or
  "insertion" times for the specified files. This is recycled, and it
  defaults to the current time and date.}
 \item{comments}{a character vector of comments, either empty or one
   string for each entry being added to the Zip file.}
 \item{globalComment}{a character string (character vector of length 1)
   used as a comment for the entire zip archive. }
}
\value{
 A logical value \code{TRUE} if successful, or an error is raised.
}
\references{
miniunzip code by Gilles Vollant
\url{http://www.winimage.com/zLibDll/minizip.html}
}
\author{
Duncan Temple Lang by adapting code from Gilles Vollant.
}



\seealso{
 \code{\link{zipArchive}}
 \code{\link[utils]{tar}}
}
\examples{
# zip("foo.zip", c("zip.xml", "FAQ.html"))

 ff = sapply(c("DESCRIPTION", "NAMESPACE"), system.file, package = "Rcompression")
 zip("Rcompression.zip", ff)

 ar = zipArchive("Rcompression.zip")
 names(ar)
 ar[["DESCRIPTION"]]

 zip("Rcompression.zip", ff, altNames = c("A", "B"))  # appending
 ar = zipArchive("Rcompression.zip")
 names(ar)
 ar[["DESCRIPTION"]] == ar[["A"]]  # should be same but FALSE.
 xx = strsplit(c(ar[["DESCRIPTION"]], ar[["A"]]), "")
 all(xx[[1]] == xx[[2]])

 zip("Rcompression.zip", ff, altNames = c("A", "B"), append = FALSE)
 ar = zipArchive("Rcompression.zip")
 names(ar)


 files = list.files(system.file("Meta", package = "Rcompression"), full.names = TRUE)
 zip("meta.zip", files)
 names(zipArchive("meta.zip"))

 names(files) = gsub("^.*Rcompression[/\\\\]", "", files)
 zip("meta.zip", files, append = FALSE)
 names(zipArchive("meta.zip"))

  # a character vector enclosed in I()
 content = I(c( myFile = "This is raw text", otherFile = paste(letters, collapse = "\n")))
 zip("asis.zip", content, append = FALSE)
 z = zipArchive("asis.zip")
 names(z)
 z[[1]]

   # A list with elements which are each I(character) and a file name
 content = list( myFile = I("This is raw text"),
                 otherFile = I(paste(letters, collapse = "\n")),
                 system.file("Meta", "nsInfo.rds", package = "Rcompression"))
 zip("asis.zip", content, append = FALSE)



   # Here we add a binary file. It is another zip file.
 f = system.file("sampleData", "MyZip.zip", package = "Rcompression")
 rw = readBin(f, "raw", file.info(f)[1, "size"])
 content$raw = rw
 zip("asis.zip", content, append = FALSE)

  # Now we read this newly created zip file and extract each of the elements
 z = zipArchive("asis.zip")
 names(z)
 z[["myFile"]]
 z[["otherFile"]]
    # Here we get the zip file we put into the zip file.
 rr = z[["raw", mode = "raw"]]
    # It is a raw vector now, but we can treat it as a Zip 
    # archive by using it as an in-memory archive.
 other = zipArchive(rr) 
 names(other)
 other[["NAMESPACE"]]


  # The labels we use for the names can have / in them. They are just
  #  labels to us. But when the external unzip facilities see these,
  #  they will create the corresponding directories.
 
content = list( "A/myFile" = I("This is raw text"), "B/otherFile" = I(paste(letters, collapse = "\n")), top = I("A string"))
zip("dir.zip", content)


  #
content = list( myFile = I("This is raw text"), otherFile = I(paste(letters, collapse = "\n")))
zip("asis.zip", content, comments = c("Hi there", "And another comment"), append = FALSE)
}
\keyword{IO}

