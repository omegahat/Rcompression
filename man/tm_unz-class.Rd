\name{tm_unz-class}
\docType{class}
\alias{tm_unz-class}
\alias{tm_unzRef-class}
\alias{as.POSIXlt-tm_unz,character-method}

\title{Representation of date and time information from a zip archive entry}
\description{
  Objects of this class provide a representation of date and time
  information
  about an entry in a zip archive file.
  The components are similar to those of the \code{POSIXlt}
  representation in R, but do not include as many fields.
  Objects can be converted \code{POSIXlt} using the
  \code{as.POSIXlt} method and from there to
  \code{POSIXct}.

  The class \code{tm_unzRef} is used to return an opaque reference to a
  C-level data structure rather than a copy of the contents of that
  structure which is what \code{tm_unz} represents.
}
\section{Objects from the Class}{
  Objects of this class are typically created in C code
  called by \code{\link{getZipInfo}} rather than directly within R.
}
\section{Slots}{
	 \describe{
    \item{\code{tm_sec}:}{Object of class \code{"numeric"} seconds (0-59)}
    \item{\code{tm_min}:}{Object of class \code{"numeric"} minutes (0-59) }
    \item{\code{tm_hour}:}{Object of class \code{"numeric"} hours (0-23)}
    \item{\code{tm_mday}:}{Object of class \code{"numeric"}  day of
      month as a number}
    \item{\code{tm_mon}:}{Object of class \code{"numeric"} month
    in year as a number (0 based?)}
    \item{\code{tm_year}:}{Object of class \code{"numeric"} year, not
      starting at 1900 as with \code{POSIXlt} but rather year 0 }
  }
}
\section{Methods}{
No methods defined with class \code{tm_unz} in the signature.
}
\references{zlib and the minizip directory in the contrib/ section.
   The code was written by Gilles Volant and adapted to R.}
\author{Duncan Temple Lang}
\note{The class definition and code to create instances of this class
  was machine generated.
}
\seealso{
  \code{\link{getZipInfo}}
  \code{\link{unz_file_info-class}}
}
\examples{
}
\keyword{classes}
