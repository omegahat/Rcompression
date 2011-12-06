compress =
function(str, size = nchar(str) * 1.01 + 13, level = integer(3))
{
  minSize = nchar(str) * 1.01 + 13
  if(size < minSize)
    size = minSize 

  .Call(R_compress, str, raw(size), as.integer(level))
}

uncompress =
function(content, size =  length(content)*10, asText = TRUE, resizeBy = 2)
{
  resizeBy = as.numeric(resizeBy)
  if(resizeBy < 1.0)
      stop("resizeBy must be greater than or equal to 1.0")
  
  .Call(R_uncompress, content, size, as.logical(asText), resizeBy)
}

gunzip  =
function(content, size = length(content) * 5, asText = TRUE)
{
  if(typeof(content) == "raw")
     .Call(R_gzuncompress, content, as.numeric(size), as.logical(asText))
  else
    stop("to uncompress a file, call the gzip system command or use the gz() function to read the contents into R.")
}  




gzip = 
function(content, level = 1, windowBits = (15 + 16), memLevel = 9, strategy = 0L, size = length(content) * 1.01 + 12)
{
  if(!is.raw(content))
     content = charToRaw(paste(as.character(content), collapse = ""))
  ans = raw(size)
  .Call(R_gzip, content, as(level, "integer"), as(windowBits, 'integer'), as(memLevel, "integer"), as(strategy, "integer"), ans)
}
