\name{unz_file_info-class}
\docType{class}
\alias{unz_file_info-class}
\alias{unz_file_infoRef-class}
\alias{ZipArchiveDescription-class}
\alias{as.data.frame,ZipArchiveDescription-method}

\title{Information about entry in zip archive file}
\description{
  This class provides a description of an individual file entry
  in a zip archive. It details, amongst other things,
  the original size and compressed size
  of the file, the version and level information of the compression
  technique, details about extra information stored in the header and
  the file system date stamp of the file at the time it was added to the
  archive.

  The \code{unz_file_infoRef} class is not explicitly used but
  is available to return a reference to a C-level  instance
  rather than providing a complete copy of it in R.
  This is convenient if one wants to a) avoid the computation of copying
  the object, or b) wants to mutate the object. The bindings are not
  here to make element-wise modifications but can be easily generated
  from the \code{RGCCTranslationUnit} package.
}
\section{Objects from the Class}{
  Typically, instances are created in C code when reading the
  zip archive file via the function \code{\link{getZipInfo}}.
  It is not necessarily useful to create instances manually within R.
}
\section{Slots}{
	 \describe{
    \item{\code{version}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{version_needed}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{flag}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{compression_method}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{dosDate}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{crc}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{compressed_size}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{uncompressed_size}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{size_filename}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{size_file_extra}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{size_file_comment}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{disk_num_start}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{internal_fa}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{external_fa}:}{Object of class \code{"numeric"} ~~ }
    \item{\code{tmu_date}:}{Object of class \code{"tm_unz"} ~~ }
  }
}
\section{Methods}{
No methods defined with class \code{unz_file_info} in the signature.
}
\references{zlib and the minizip directory in the contrib/ section.
   The code was written by Gilles Volant and adapted to R.}
\author{Duncan Temple Lang}
\note{The class definition and code to create instances of this class
  was machine generated.
}

\seealso{
\code{\link{getZipInfo}}
}
\examples{

}
\keyword{classes}
