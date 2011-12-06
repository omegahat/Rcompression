####################################################################
#
# Functions for writing to the archive. Currently use the file system
# but would like to do it in memory.
#
# !!! Can now use zip() to do in memory.
#


   # Vector of length 2 giving the archive and the filename within that.
setClass("ZipArchiveEntry", contains = "character", prototype = as.character(c(NA, NA)))


setMethod("[<-", "ZipArchive",
#"[<-.ZipArchive" =
  # ... allows password and mode.
  # i can be a character 
function(x, i, j, ..., password = character(), replace = TRUE, mode = "", value)
{
  if(!is.list(value))
     value = list(value)

  w = list(...)

  if(!missing(j))
    w = c(j, w)
  if(!missing(i))
    w = c(i, w)

    # if different length, then why are you wanting to add the
    # same file multiple times under different names. Use
    # relationships within Open Packaging files (.docx, etc.)
  names(value) = as.character(unlist(w))
  updateArchiveFiles(x, value, replace = replace, ...)
})

setMethod("[[<-", "ZipArchive", 
  # ... allows password and mode.
  # i can be a character 
function(x, i, j, ..., password = character(), mode = "", replace = TRUE, value)
{
  if(missing(i)) {
    if(inherits(value, "AsIs"))
         stop("need a name for the element")
    i = as.character(value)
  }

  updateArchiveFiles(x, structure(list(value), names = as.character(i)), replace = replace, ...)
})


setMethod("$<-", "ZipArchive",
 # "$<-.ZipArchive" =
 # Does not allow for password. Use [[<-.ZipArchive
function(x, name, value)
{
 return( updateArchiveFiles(x, structure(list(value), names = name), replace = TRUE))

# Should probably use updateArchiveFiles()
  zip(x, structure(list(value), names = name), append = TRUE)
  x@elements = c(x@elements, name)
  if(nrow(x@info)) {
    tmp = x@info[1, ]
    tmp[1, "entry_name"] = name
    tmp[1, "uncompressed_size"] = length(value) # if file, get size of file.
    x@info = rbind(x@info, tmp)
    if(length(rownames(x@info)) && !any(duplicated(c(rownames(x@info), name))))
       rownames(x@info)[nrow(x@info)] = name
    else
       rownames(x@info) = NULL
  }
  
  x
})

zipEntrySize =
  # What is the uncompressed_size of the object being added to the zip file.
function(x)
{
  if(is.raw(x))
    length(x)
  else if(any(inherits(x, "AsIs")))
    nchar(x)
  else if(is.character(x)) {
     if(!file.exists(x))
       1L
     else
       file.info(x)[1, "size"]
  } else
   1L
}


setGeneric("updateArchiveFiles",
           function(archive, values, replace = TRUE, origVals = archive[,, mode = "raw"], ...) {
              standardGeneric("updateArchiveFiles")
           })

setMethod(updateArchiveFiles, "ZipFileArchive", 
  function(archive, values, replace = TRUE, 
              origVals = archive[,, mode = "raw"], ...) {
   newNames = c(archive@elements, names(values))
   info = archive@info   
   if(replace && any(names(values) %in% archive@elements)) {
            # if any of the new values are overwriting
            #  existing elements in the archive
        origVals[names(values)] = values
        newNames = c(archive@elements, setdiff(names(values), archive@elements))
        i = names(values)
        append = FALSE
        info[i, "uncompressed_size"] = sapply(values, zipEntrySize) # if a file, then we don't know its size.
        info[i, "entry_name"] = names(values)
        values = origVals        
   } else {
     i = seq(along = values) + nrow(info)
     info[i, "uncompressed_size"] = sapply(values, zipEntrySize) # if a file, then we don't know its size.
     info[i, "entry_name"] = names(values)
     append = TRUE
   }
   info[i, "date"] = as.POSIXct(Sys.time())        

   if(!any(duplicated(info[, "entry_name"])))
     rownames(info) = info[, "entry_name"]

    zip(as(archive, "character"), values, append = append, time = info[names(values), "date"])

     # update elements and info
    archive@elements = newNames
    archive@info = info
    archive@readTime = Sys.time()
   archive
  })


setMethod(updateArchiveFiles, "RdzArchive", 
  function(archive, values, replace = TRUE, origVals = archive[,, mode = "raw"], ...,
            .classes = as.charater(rep(NA, length(values))),
              .sizes = rep(as.integer(NA), length(values)))
   {

   if(replace && any(names(values) %in% archive@elements)) {
      if(".toc" == archive@elements[1]) {
         toc = unserialize(origVals[[1]])
         toc[names(values), "size"] = as.integer(.sizes)
         toc$class = as.character(toc$class)
         toc[names(values), "class"] = .classes
         origVals[[1]] = serialize(toc, NULL)
      }
      allUpdated = TRUE
   }

     # callNextMethod() does  not pass the origVals since it is not in the actuall call.
   as(updateArchiveFiles(as(archive, "ZipFileArchive"), values, replace, origVals = origVals, ...), "RdzArchive")
  })
