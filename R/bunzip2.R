bunzip2  =
function(content, size = length(content) * 5, verbose = 0, asText = TRUE)
{
  if(typeof(content) == "raw")
     .Call(R_bz2uncompress, content, as.numeric(size), as.integer(verbose), as.logical(asText))
  else
    stop("to uncompress a file, call the bunzip2 system command.")
}  
