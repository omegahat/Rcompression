collectContents =
function(entries = character())
{
  ans <- vector("list", length(entries))
  names(ans) <- entries

  store =
    function(contents, filename) {

      if(length(entries) == 0 || filename %in% entries) {
        ans[[filename]] <<- contents
        TRUE
      } else
        FALSE
    }

  .ans = function(convert = NULL, ...) {

    if(length(convert) == 0)
      return(ans)

    if(is.function(convert)) 
      return(sapply(ans, convert, ...))

    if(is.list(convert)) 
      return(mapply(convert, names(ans), ...,
                      function(f, id, ...) f(id, ans[[id]], ...)))

    
    warning("Don't understand how to use the convert argument")
    ans
  }
  
  structure(list(store = store, .ans = .ans),
            class = c("TarExtractCallback", "TarCallback"))
}


tarExtract =
function(filename, entries = character(), op = collectContents(entries), convert = NULL,
           data = NULL, workBuf = raw(10000), ...)
{
  if(!is.raw(filename)) {
     if(!file.exists(filename))
        stop("Cannot find file ", filename)
     else
       filename = path.expand(filename)
  }

  if(!is.null(workBuf)) {
      if( is(workBuf, "numeric") )
        workBuf = raw(workBuf)
      else
        workBuf = as.raw(workBuf)
  }
     
  f = if(inherits(op, "TarExtractCallback")) op$store else op

  .Call(R_tarExtract, filename, as.character(entries), f, data, workBuf)
  if(inherits(op, "TarExtractCallback"))
      op$.ans(convert, ...)
  else
      op    
}

tarInfo =
function(filename, fun = tarListCallback(), data = NULL)
{
  if(!is.raw(filename)) {
     if(!file.exists(filename))
        stop("Cannot find file ", filename)
     else
       filename = path.expand(filename)
  }

    f = if(inherits(fun, "TarInfoCallback"))   fun$callback else fun
    .Call(R_tarInfo, filename, f, data)

    if(inherits(fun, "TarInfoCallback"))
      fun$.ans()
    else
      fun
}  


tarListCallback =
function()
{
  ans = list(file = character(),
             type = character(),
             timestamp = numeric(),
             size = integer())
  cb = 
  function(filename, entryType, time, size, counter) {

    ans$file <<- c(ans$file, filename)
    ans$type <<- c(ans$type, entryType)
    ans$timestamp <<- c(ans$timestamp, time)
    ans$size <<- c(ans$size, size)

    TRUE
  }

  structure(list(callback = cb,
                 .ans = function(convert = TRUE) {
                               if(!convert)
                                   return(ans)
                               
                               ans$time = ISOdatetime(1970, 1, 1, 0, 0, 0) + ans$time
                               TypeNames = .Call(R_getTarTypeNames)
                               ans$type = names(TypeNames)[match(ans$type, TypeNames)]
                               ans = as.data.frame(ans)
                               ans$file = I(as.character(ans$file))
                               ans
                        }
                ),
            class = c("TarInfoCallback", "TarCallback"))
}  
