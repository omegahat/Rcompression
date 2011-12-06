\name{ZipFileArchive-class}
\Rdversion{1.1}
\docType{class}
\alias{ZipArchive-class}
\alias{ZipFileArchive-class}
\alias{ZipMemoryArchive-class}
\alias{ZipArchiveEntry-class}


\title{Classes related to Zip archives}
\description{
  These classes represent Zip archives within a file (\code{ZipFileArchive}),
  within a memory buffer (\code{ZipMemoryArchive}), and individual entries
  within a Zip archive ((\code{ZipArchiveEntry}).
}
\section{Objects from the Class}{

}
\section{Slots}{
  \describe{
    \item{\code{.Data}:}{Object of class \code{"character"} ~~ }
    \item{\code{classes}:}{Object of class \code{"character"} ~~ }
    \item{\code{elements}:}{Object of class \code{"character"} that
       gives the names of the elements within an archive.
 }
  }
}
\section{Extends}{
Class \code{"\linkS4class{character}"}, from data part.
Class \code{"\linkS4class{ZipArchive}"}, directly.
Class \code{"\linkS4class{vector}"}, by class "character", distance 2.
%Class \code{"\linkS4class{data.frameRowLabels}"}, by class "character", distance 2.
%Class \code{"\linkS4class[RAutoGenRunTime]{EnumerationValue}"}, by class "character", distance 2.
}
\section{Methods}{
No methods defined with class "ZipFileArchive" in the signature.
}

\author{Duncan Temple Lang}

\seealso{
  The \code{ROOXML} package uses these to access elements
  of a Office Open XML document.
}
\examples{
showClass("ZipFileArchive")

  out = paste(tempfile(), "zip", sep = ".")
  dir = system.file("R", package = "Rcompression")
  zipFile = system(paste("zip -r", out, dir))
  ar = zipArchive(out)
  names(ar)
  ar[[ "bob" ]] = system.file("DESCRIPTION", package = "Rcompression")
  ar[[  ]] = system.file("INDEX", package = "Rcompression")

}
\keyword{classes}
