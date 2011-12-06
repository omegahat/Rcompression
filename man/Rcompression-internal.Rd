\name{unzFileRef-class}
\docType{class}
\alias{unzFileRef-class}
\alias{unz_global_info-class}
\alias{unz_global_infoRef-class}
\alias{unz_global_infoRef-class}
\title{Internal classes used in the Rcompression package.}
\description{
  These classes need to be accessible for the C code to work
  but are not used directly by the R user.
}
\section{Objects from the Class}{
 Created internally by C code and non-exported R functions.
}
\section{Slots}{
	 \describe{
    \item{\code{ref}:}{Object of class \code{"externalptr"} the
      reference to the C-level structure.}
    \item{\code{classes}:}{Object of class \code{"character"}
      the names of the C++ classes which such objects can be
      legitimate members. This is checked when passing an R object
      to a C/C++ routine.}
  }
}
\section{Extends}{
Class \code{"RC++Reference"}, directly.
}
\section{Methods}{
No methods defined with class "unzFileRef" in the signature.
}
\references{}
\author{}
\note{}

\seealso{
}
\examples{
}
\keyword{classes}
