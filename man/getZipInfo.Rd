\name{getZipInfo}
\alias{getZipInfo}
\title{Read table of contents from zip archive}
\description{
  This function reads the specified zip file and
  returns information about each file contained in the archive.
  This can be useful when one wants to find out what files are in
  an archive without unzipping the file  or reading
  the contents via a call to the system zip command, e.g. zip -l,
  and parsing the results.
  All the manipulations are done in memory and require no disk access.
  This can be returned as a list with an object for each file,
  or as a data frame with a row for each element.
}
\usage{
getZipInfo(filename, asDataFrame = TRUE, filename.size = 1024,
            comment = TRUE)
}
\arguments{
  \item{filename}{the name of the zip file. This can contain ~ which is
    expanded using \code{\link[base]{path.expand}}.}
  \item{asDataFrame}{a logical value indicating whether to convert the
    simple list of information objects to a rectangular table.
    This involves a non-trivial number of computations at present
    (unoptimized!) and so it may wise to avoid this for very large zip
    files   if one is interested in a single field.
  }
  \item{filename.size}{the number of bytes to use for the string used as the work space for the file names in the
    archive. This allows the user to enlarge the work space for archives
    with very long file names, including the directories.}
  \item{comment}{a logical value controlling whether the comments should
  be retrieved (\code{TRUE} for retrieve).}
}
\details{
  This uses the code from the minizip directory in the zlib
  distribution. The code was created and is copyrighted by
  Gilles Volant.  There were some minor changes
  to ANSI'fy  the C code routine definitions to make it
  accesible to a C++ compiler. This was needed so as to be
  able to automate the code that interfaced to the
  native routines and data structures using the
  RGCCTranslationUnit package from the omegahat.org
  Web site.
}
\value{
  If \code{asDataFrame} is \code{TRUE}, a data frame with
  15 columns. These corrspond to the fields of the
  \code{\link{unz_file_info-class}} class.

  If \code{asDataFrame} is \code{FALSE}, the return value
  is a named list containing the \code{\link{unz_file_info-class}}
  objects
}
\references{
 \url{http://www.gzip.org/zlib/} zlib
}
\author{Duncan Temple Lang}
\note{
  This code builds on the internal functions that are
  automatically generated using RGCCTranslationUnit
}
\seealso{
 \code{\link[base]{connections}}
}
\examples{

  zipFile = system.file("sampleData", "MyZip.zip", package = "Rcompression")
  df = getZipInfo(zipFile)
  df[grep("^R/", rownames(df)), ]
  weekdays(df$date)


  # Treating the files element-wise rather than in a data frame.
  els = getZipInfo(zipFile, FALSE)
  sapply(els, slot, "compressed_size")/sapply(els, slot, "uncompressed_size")

   # Get the month the file was last modified.
   # This is in the tmu_date slot of each element.
  sapply(els, function(x) x@tmu_date@tm_mon)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{IO}

