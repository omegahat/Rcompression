\name{loadZip}
\Rdversion{1.1}
\alias{loadZip}
\alias{readBinaryFile}
\title{
Read the contents of a file as binary  into a raw vector.
}
\description{
We use this function to read the contents of a zip file
into memory. This is a general function and can be used
to read arbitrary files, including any binary file.
It determines the length of the file and reads that many bytes
and so removes the need for the caller of 
\code{\link[base]{readBin}} to know how many bytes are in
the file.
}
\usage{
readBinaryFile(filename)
loadZip(filename)
}
\arguments{
  \item{filename}{the full path identifying the file}
}
\value{
 A raw vector with length corresponding to the number
of bytes in the file.
}
\author{
Duncan Temple Lang
}

\seealso{
\code{\link[base]{readBin}}
}
\examples{
  data = loadZip(system.file("sampleData", "Empty.docx", package = "Rcompression"))
  ar = zipArchive(data)
  names(ar)
}
\keyword{IO}
