\name{collectContents}
\alias{collectContents}
\title{Tools to gather the contents of one or more elements of an archive}
\description{
 This function creates an object which contains functions
 that are used in collecting the contents of elements in 
 an archive file.  We typically call this function
  with the names of the elements in the archive in which we  
 are interested.  This amounts to a filter.
  Then, as we iterate over the contents of the archive in a function
  such as \code{\link{tarExtract}}, at the start of each element 
  the callback/handler function is invoked and in the case
  of \code{collectContents}, it either ignores the element
  if the name is not in this collection of ``target'' entries, or
  else it stores the contents of that entry  in a list using the entry
  name as the key.
  The results can be retrieved from the internal state of these
  functions using the \code{.ans} element of the list.
  By default, this returns the list of entry contents. Optionally,
  this function can be given a converter function which is 
  applied element-wise to the entry content list.
  And if a  list  of converter functions is passed, 
  then the function is applied to the 
  to the corresponding element of the entry contents list and the list returned.


}
\usage{
collectContents(entries)
}
\arguments{
  \item{entries}{character vector giving the (full) names of the
    entries in which we are interested.  If the names do not match,
    
  }
}
\value{
 This returns an S3 object of class 
  \code{TarExtractCallback} and \code{TarCallback}.
 This identifies that the \code{store} element can be used within 
  the tar iterator function \code{\link{tarExtract}}.
  The second element \code{.ans} is a function that can be used to
  retrieve the results that are gathered during the different
  invocations to the \code{store} function.
}
\author{Duncan Temple Lang}
\seealso{ 
 \code{\link{tarExtract}}
}
\examples{

}
\keyword{IO}
\concept{compression}
\concept{callback}

