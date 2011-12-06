\name{updateArchive}
\Rdversion{1.1}
%\alias{updateArchive}
\alias{updateArchiveFiles}
\alias{updateArchiveFiles,RdzArchive-method}
\alias{updateArchiveFiles,ZipFileArchive-method}
\title{Add the contents to a zip file.}
\description{
This function allows the caller to update
the contents of a Zip archive, adding or overwriting existing
entries within an archive, leaving others umodified.

It is often more convenient to use
the \code{[<-} operator to add/update
elements of an archive, e.g.
\code{archive[ c("a", "b") ] = list(I("Some text"), "myFile")}

\code{updateArchive} currently works for zip files only,
but it can be made generic and methods can be easily 
added for different types of archives (e.g. tar files)
assuming the underlying functionality to add the files is
available.

This function now (as of version 0.91-0 of this package)
uses in-memory rather than temporary files and the external
zip executable.

%\code{updateArchiveFiles} is a higher-level function 
%that knows about XML files and is used for Office  Open
%file format. This function will  most likely be moved to 
%a different package in  the future, e.g. \code{ROOXML}.
%
%Why do we have \code{dir} and \code{fileNames}?
%The reason is that the file names identify the elements within the
%archive and so must be given without any prefix path.
%\code{dir} serves as this prefix path. 
}
\usage{
updateArchiveFiles(archive, values, replace = TRUE,
                    origVals = archive[,, mode = "raw"], ...)
}
\arguments{
  \item{archive}{the ZipArchive object.}
  \item{values}{a named list of entries to add. These are passed to \code{\link{zip}}.}
  \item{replace}{a logical value that controls whether existing elements
 in the archive  with the same names as any being added are overwritten,
 i.e. replaced, or whether we just append \code{values} to the end of
 the archive regardless of name conflicts.}
  \item{origVals}{this is a parameter so that methods which need to
 retrieve all the entries in the zip file can pass these to other
 methods and avoid having to read them multiple times.}
  \item{...}{any additional, supporting files such as images, style
    files, etc. 
     which are updated in the rels/ component of the document}  
% \item{fileNames}{the names of the files to be added
%      the archive. 
%      When this function is called, these should be
%      files in the file system, located under
%     \code{dir}.
%      Other, higher-level functions can work with 
%      the contents directly rather than files.
% }
% \item{dir}{The directory in which to find the specified files.}
% \item{verbose}{a logical value indicating whether to emit 
%   information about the steps being performed.}
% \item{zip}{a string identifying how to invoke the zip shell command}
% \item{.files}{an alternative to ... which is useful when one already has
%  the additional files in a list.}
% \item{doc}{the document to be added, typically the central document
%   of an Office Open file. The .files/... are the supporting/related files
%   such as images, styles, etc. }
}
\details{
}
\value{

}
\references{
The zip command-line utility.
}
\author{
Duncan Temple Lang
}
\seealso{
 \code{\link{zipArchive}}
}
\examples{
}
\keyword{IO}
\concept{Zip archive}
