zave = 
# Equivalent of save() but individual elements are inserted into a zip file
  #
  # allow the caller to give us a collection of name = value pairs
  # We find the values and serialize each one to a separate file
  # then we zip up the entire collection.
  #
function(..., list = character(), file = stop("Must specify file name"),
          envir = parent.frame(), compression_level = 9, .addToc = TRUE, append = FALSE)
{
   if(!missing(list)) {
     if(is.character(list))
        vals = structure(lapply(list, function(x) get(x, envir)), names = list)
     else
        vals = list
   } else {
      vals = list(...)

        # Get the names of the variables.
        # User could specify a = x, other = y and we use those names in the zip, i.e. a and other.
        # But if they specify zave(x, y, file = "bob"), we use x and y
      kall = match.call()[-1]
      i = names(kall) %in% c("list", "file", "envir", "compression_level", ".addToc", "append")
      syms = sapply(kall[!i], as.character)
      j = names(kall[!i]) != ""
      syms[j] = names(kall[!i])[j]
     names(vals) = unlist(syms)
   }

  ser = structure(lapply(vals, function(x) serialize(x, NULL)), names = names(vals))

  if(.addToc) {
      # We should add this to the front of the 
      # of the list so that we can read it quickly.
      # We would also like to get the offset from the
      # start of the file for each object so we could
      # jump directly to that point to read a particular object
      # rather than have to read all the ones before this.
      # But we also want the TOC to be at the end of the file
      # so we can append new objects to it and just overwrite 
      # this toc and add a new one after it.
     toc = data.frame(class = sapply(vals, class), 
                            size = sapply(vals, object.size),
                            row.names = if(!any(duplicated(names(vals)))) names(vals) else NULL)
 
        # Add this at the beginning.
        #  Use append()!
      tmp = list(serialize(toc, NULL))
      tmp[seq(2, length = length(ser))] = ser
      names(tmp) = c(".toc", names(vals))
      ser = tmp
  }
  

     # Now serialize this to a file.
  if(zip(file, ser, compression_level = compression_level, append = append))
     Rdz(file)
  else 
     stop("Error creating zip file")
}

setClass("RdzArchive", contains = "ZipFileArchive")

Rdz = 
function(filename, check = TRUE, class = "RdzArchive")
{
  zipArchive(filename, class = class, check = check)
}

setMethod("[", c("RdzArchive", "missing", "missing"),
          function(x, i, j, ..., password = character(), mode = "raw", drop = TRUE) {
             vals = readAllZipEntries(x, password, mode, x@info) # callNextMethod()
             if(!missing(mode) && mode == "raw")
                structure(vals, names = names(x))
             else
                structure(lapply(vals, unserialize), names = names(x))
#             val = getZipFileEntry(x, i, mode = mode)
#             unserialize(val)
          })


setMethod("[[", c("RdzArchive", "character", "missing"),
          function(x, i, j, ..., mode = "raw", last = TRUE) {
           
#         if(last) {
#           w = i == names(x)
#           if(!any(w))
#              stop("No such element")
#            w = which(w)[sum(w)]
#            x[[ w ]]
#          } else {
#           val = getZipFileEntry(x, i, mode = mode)
#           unserialize(val)
#          }
               # need to explicitly pass the mode and last or else
               # they are missing and we use the defaults for ZipArchive
            val = callNextMethod(x, i, mode = mode, last = last)
            unserialize(val)
          })

setMethod("[[", c("RdzArchive", "numeric", "missing"),
          function(x, i, j, ..., mode = "raw") {
             val = getZipFileEntry(x, i, mode = mode)
             unserialize(val)
          })


setMethod("$", c("RdzArchive"),
          function(x, name) {
             x[[name, last = TRUE]]
#             val = getZipFileEntry(x, name, mode = "raw")
#             unserialize(val)
          })


setMethod("[[<-", c("RdzArchive", "character"),
           function(x, i, j, ..., replace = TRUE, mode = "raw", value) {
            klass = class(value)
            size = object.size(value)
            value = serialize(value, NULL)
            updateArchiveFiles(x, structure(list(value), names = i), replace = replace,
                                .classes = klass, .sizes = size)
           })

setMethod("$<-", c("RdzArchive"),
          function(x, name, value) {
            x[[name ]] <- value
#            callNextMethod()
#             zip(x, structure(list(serialize(value, NULL)), names = name), append = TRUE)
#             x
          })


setMethod("load", "RdzArchive",
          function (file, envir = parent.frame())  {
            lapply(names(file), 
                    function(id)
                       assign(id, file[[id]], envir))
            invisible(names(file))
          })
         
if(FALSE) {
 library(Rcompression)
 x = 1:10
 y = letters
 bob = zave(x, y, mtcars, other = x, file = "/tmp/bob.zip", bob = 1:10)
# or  bob = Rdz("/tmp/bob.zip")
 names(bob)
 bob[["y"]]
}
