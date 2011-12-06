\name{tarExtract}
\alias{tarExtract}
\title{Extract the contents of entries in a gzipped tar file}
\description{
  The initial version of this function provides a mechanism
  to extract entries in a gzipped tar file directly into R.
  By default, this returns the contents of each specified
  entry  as a \code{raw} vector.
  However, the caller can specify a function that will process each
  entry when its entire contents are available such as to convert
 the RAW vector to a character, or even to read data from the files.
  This allows one to then discard the results.

  The function now supports reading from RAW data rather than a file.
  For example, one can read the contents of a bzip2 or gz  archive
  obtained from a file or from a stream such as via an HTTP query
  via \code{RCurl}.  Then one can extract the contents of the \dQuote{files}
  from the memory representation of the archive and there is no need
  to deal with the file system. This avoids cleanup and makes \dQuote{security}
  issues simpler.
}
\usage{
tarExtract(filename, entries = character(),
            op = collectContents(entries),
             convert = NULL, data = NULL,
              workBuf = raw(10000), ...)
}
\arguments{
  \item{filename}{the name of the gzipped tar file or alternatively a
  raw vector containing the uncompressed archive contents, e.g. when
  read from a gz or bzip2 stream.}
  \item{entries}{a character vector giving the precise
    names of the files to extract (see \code{\link{tarInfo}} to find
    the names). If this is empty (the default), all entries are
    extracted and returned.

    In the future, also a function that takes a single
    entry name and returns \code{TRUE} or \code{FALSE}
    indicating whether to extract the contents of the specified file.
    This dynamic matching is not yet implementd and is not necessary
    as the names of the desired files can be determined via a two-pass
    procedure of getting the table of contents for the archive
    and then applying the function.  In different cases,
    there may be different performance gains. If we use a matching
    function, there is the overhead of a function call from C.
    However, the two passes of a large archive might be expensive
    if it is very large.
   }
  \item{op}{an R function that is invoked when the entire contents
    of a particular entry are available.
    This is called with the the contents
    which are given in a \code{\link[base]{raw}} vector
    and the name of the entry, in that order.
  }
  \item{data}{a user-defined data value that is passed to the
    call to the  native routine specified in \code{op}, if
    that is not an R function.}
  \item{convert}{a function or list of functions which
    if provided are used to convert the raw vectors
    after they have been collected.
    This is done when the result is fetched.
  }
  \item{workBuf}{a raw vector or  \code{NULL},
    or a number which is used to create a raw vector of that length.
    This used as a buffer to copy the contents of the entire file
    as each chunk is delivered from the extraction.
    By making this a long raw vector, we reduce the
    number of times we need to enlarge the vector
    to store the entire entry's contents.
    Of course, the larger it is, the more memory
    we need. If one wants to optimize the speed
    of extraction, one can create a raw vector
    with length equal to the largest
    file size to be extracted. One can use
    \code{\link{tarInfo}} to find this information.
 }
 \item{...}{additional arguments passed on to the call
   to fetch the result and to the \code{convert} function
   if specified.
    (More details needed.)
 }
}
\details{
 
}
\value{
  By default, a list with an element  for each entry specified.
  The content of each element is a \code{\link[base]{raw}}
  vector.  If it is \code{NULL}, then the entry was not found
  in the archive.
}
\references{
 zlib/contrib/untgz
}
\author{Duncan Temple Lang}
\note{
  The details may change a little in future versions.
}
\seealso{
 \code{\link{tarInfo}}
}
\examples{

  filename = system.file("sampleData", "OmegahatXSL_0.2-0.tar.gz", package = "Rcompression")

     # Get the contents of two files.
  raws = tarExtract(filename, c("OmegahatXSL/XSL/env.xsl", "OmegahatXSL/XSL/Todo.xsl"))
     # Now convert the raw vectors to text since we know what we are
     # dealing with.
  sapply(raws, rawToChar)

    # or in one step
  raws = tarExtract(filename, c("OmegahatXSL/XSL/env.xsl", "OmegahatXSL/XSL/Todo.xsl"), convert = rawToChar)


     # Extract files in a directory.
  filename = system.file("sampleData", "OmegahatXSL_0.2-0.tar.gz", package = "Rcompression")
  i = tarInfo(filename)

     # Check there is such a directory
  i$type == "DIRTYPE" & i$file == "OmegahatXSL/XSL/"

  files = i$file[dirname(i$file) ==  "OmegahatXSL/XSL"]
  z = tarExtract(filename, files, convert = rawToChar)
  nchar(z)

    # This example illustrates how we can process the contents of each
    # file as it is extracted.
    # The particular computation is uninteresting but the approach is intended
    # to illustrate that we can extract some information from the
    # contents and put it somewhere and move on to the next file. This
    # is useful if the archive has data across multiple files that can
    # be dymaically merged into a single R data structure.
 
  filename = system.file("sampleData", "OmegahatXSL_0.2-0.tar.gz", package = "Rcompression")
  lineCounts = numeric()
  countLines =
     function(contents, fileName = "", verbose = TRUE) {

        if (verbose) cat(fileName, "\n")
        numLines = length(strsplit(rawToChar(contents), "\\\n")[[1]])
        lineCounts[fileName] <<- numLines
        numLines
     }
  i = tarInfo(filename)
  files = i$file[!( i$type \%in\% "DIRTYPE")]

    # Now we are ready to run the code.
  tarExtract(filename, files,  countLines)


    # Alternatively, collect all the information and then
    # convert each one in turn at the end.
    # This is only marginally faster, if at all and consumes
    # a lot more memory as when we perform the conversion
    # we have all of the contents in memory.
    # One measurment of speed was 38 seconds to 39.

    # With the changes to avoid the accordion growth of the raw
    # vector for each chunk of file, the comparison
    # is .969 versus .537.  So much faster overall, and this
    # version becomes relatively quicker.  But consumes more memory.

  tarExtract(filename, files,  convert = countLines, verbose = FALSE)

  max(i$size)

  # Dealing with raw data rather than a file.
 filename = system.file("sampleData", "OmegahatXSL_0.2-0.tar.bz2", package = "Rcompression")
 f = bzfile(filename, "rb")
 data = readBin(f, "raw", 1000000)
 close(f)

 tarInfo(data)

 targetFiles = c("OmegahatXSL/XSL/env.xsl", "OmegahatXSL/XSL/Todo.xsl")
 raws = tarExtract(data, targetFiles, convert = rawToChar)


 filename = system.file("sampleData", "OmegahatXSL_0.2-0.tar.gz", package = "Rcompression")
 f = gzfile(filename, "rb")
 data = readBin(f, "raw", 1000000)
 close(f)

 tarInfo(data)
}
\keyword{IO}
\concept{compression}
\concept{archive}
