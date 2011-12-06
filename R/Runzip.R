# Special class for data frame describing the contents of a ZipArchive.
setClass("ZipArchiveDataFrame", contains = "data.frame")


string =
function(len)
   paste(rep(".", len), collapse = "")

readAllZipEntries =
   # Attempt to take advantage of the fact that we are reading all the elements
   # of a ZipArchive so we can work sequentially and not have to zoom around
   # look for each element.
function(filename, password = character(), mode = "", info = getZipInfo(filename))
{
  if(is(filename, 'unzContentRef')) {
     h = filename
  } else {
     h = as(filename, 'unzFileRef')   
     on.exit(unzClose(h))
  }

  ginfo = unzGetGlobalInfo(h)
  unzGoToFirstFile(h)
  buf = string(1000)
  vals = lapply(info[,"uncompressed_size"],
           function(len) {
               el = unzGetCurrentFileInfo(h, buf, nchar(buf), raw(0), 0, character(), 0)
               ans = readCurrentZipFile(h, password, len, mode)
               unzGoToNextFile(h)
               ans
           })
  names(vals) = rownames(info)
  vals
}


getZipInfo =
function(filename, asDataFrame = TRUE, filename.size = 1024, comment = TRUE)
{
  if(is(filename, "raw")) {
     h = as(filename, 'unzMemoryRef')   
     # ??? Do we need to free this.
     #  on.exit(unzClose(h))    
  } else if(is(filename, 'unzContentRef'))
     h = filename
  else {
     h = as(filename, 'unzFileRef')   
     on.exit(unzClose(h))
  }

  if(is.logical(comment)) {
    comment = if(comment) paste(rep(".", 1000), collapse = "") else character()
  } else if(is.numeric(comment))
    comment = paste(rep(".", 1000), collapse = "")

  info = unzGetGlobalInfo(h)

  buf = paste(rep(".", filename.size), collapse = "")

  unzGetCurrentFileInfo(h, buf, filename.size, raw(0), 0, character(), 0)

  unzGoToFirstFile(h) # not really necessary as we just opened the file.

  els = lapply(seq(length = info$pglobal_info@number_entry), 
               function(i) {
                 #XXX want to use the global one numerous times. Here to see if there is a reference problem.
        k = paste(rep(".", 1000), collapse = "")
                 ans = unzGetCurrentFileInfo(h, buf, filename.size, raw(0), 0, k, nchar(k))
                 unzGoToNextFile(h)
                 ans
             })

   # Get the file names
  names(els) = sapply(els, function(x) x$szFileName)

  if(length(comment))
    comments = sapply(els, "[[", "szComment" )
  
   # Get just the unz_file_info objects.
  els = lapply(els, function(x) x[[2]])

#  class(els) <- "ZipArchiveDescription"
  els = structure(els, class = c("ZipArchiveDescription", "data.frame"))
 
  if(asDataFrame) {
     # We do this as a data frame first and then make the ZipArchiveDataFrame
     # as x$foo = val for a sub-class of data.frame gives a warning
     # about "Setting class(x) to NULL;  "
    tmp = data.frame(els, row.names = if(any(duplicated(names(els))))
                                        1:length(els)
                                      else
                                        names(els))
    tmp$entry_name = names(els)
    if(length(comment))
       tmp$comment = comments
    structure(new("ZipArchiveDataFrame", tmp),
              zip.file = filename)
  } else
    els

}

as.data.frame.ZipArchiveDescription <-
function(x, row.names = NULL, optional = FALSE, ...)
{
  slotNames = names(getSlots(class(x[[1]])))[-15]

  tmp =
       lapply(slotNames,
          function(slotName) {
            sapply(x, function(v) slot(v, slotName))
          })
  names(tmp) <- slotNames
  ans = as.data.frame(tmp, names(x))

   # Need to take each object and put it into a POSIXct.
   # Go through POSIXlt first? since that is the similar format.
  tmp = sapply(x, function(el) as.POSIXct(as.POSIXlt.tm_unz(el@tmu_date)))
  class(tmp) <- c("POSIXt", "POSIXct")
  ans$date = tmp

  ans
}

as.POSIXlt.tm_unz <-
function(x, tz = "", ...)
{
  slotNames = names(getSlots(class(x)))
  vals <- lapply(slotNames,
                  function(id) slot(x, id))
  names(vals) <- gsub("^tm_", "", slotNames)

  vals$year = vals$year - 1900
  vals$wday = NA
  vals$yday = NA
  vals$isdist = 1

  attr(vals, "tzone") <- tz
  class(vals) <- c("POSIXt", "POSIXlt")

  strptime(vals, "%Y-%m-%d %H:%M:%S")
}  
  
getZipFileEntry =
function(archive, el, password = character(), mode = "character",
         info = getZipInfo(archive), nullOk = FALSE, last = TRUE)
{
  if(is.character(archive))
     archive = path.expand(archive)

   # Don't actually need the info if el is a number.
   # But we do need the size. 
   #  class(info) = class(info)[-1]
  
  if(is.character(el)) {
    elNames = info[, "entry_name"]
    if(last) {
      i = length(elNames) - pmatch(el, rev(elNames)) + 1
    } else 
      i = pmatch(el, elNames) # rownames(info)
    
    if(is.na(i)) {
       i = agrep(el, rownames(info))
       if(length(i) == 0 && substring(el, 1, 1) == "/")
                # if the user gave us an absolute name, i.e. starting with /
          i = agrep(el,  paste("/",rownames(info), sep = ""))
       if(length(i) == 0)
          if(nullOk)
             return(NULL) # Need to do this in a vectorized manner.
          else
             stop("no entry matching ", el, " in the ZIP archive ", archive)
     }
  } else {
    i = as.integer(el)
    if(length(i) == 1 && (i < 1 || i > nrow(info)))
       stop("index for ZIP element out of bounds")
  }

  if(length(i) > 1)
      return(lapply(i, function(i) getZipFileEntry(archive, i, password, mode, info = info)))  
  
  len = info[i, "uncompressed_size"]
  if(len == 0)
     return(character())

#  if(is(archive, "unzContentRef"))
#    f = archive
#  else {
       # Does a reset or explicit reopen.

    f = unzOpen(archive)
    on.exit(unzClose(f))
#  }

  moveToZipEntry(f, i)

  readCurrentZipFile(f, password, len, mode)
}

moveToZipEntry =
function(f, i)
{
  pos = 1
  while(pos < i) {
     unzGoToNextFile(f)
     pos = pos + 1
  }  
}

readCurrentZipFile =
function(stream, password = character(), len = NA, mode = "")
{
#  is(stream, "ZipMemoryArchive")
#     .Call("R_unzMemoryRef_reset", stream)
#  else 
    if(.Call("R_unzOpenCurrentFilePassword", stream, as.character(password)) != 0)
      stop("Can't open current file in the archive")
 
  buf = if(mode %in% c("binary", "raw")) 
           raw(len)
        else
           paste(rep(".", len), collapse = "")

  if(.Call("R_unzReadCurrentFile", stream, buf, len))
     buf
  else {
    elName = paste(rep(".", 1024), collapse = "")
    x = unzGetCurrentFileInfo(stream, elName, nchar(elName), raw(0), 0, character(), 0)    
    stop("Failed to read element from ZIP archive: ", x$szFileName)
  }
}

if(FALSE) {
"$.ZipArchiveDataFrame" =
function(x, name)
{
  filename = attr(x, "zip.file")
  getZipFileEntry(filename, name, info = x)
}


"[[.ZipArchiveDataFrame" =
  # ... allows password and mode.
  # i can be a character or a number
  # Need to implement as number.
function(x, i, ..., password = character(), mode = "")
{ 
  filename = attr(x, "zip.file")
  ans = getZipFileEntry(filename, i, password, mode, info = x)
  if(length(ans) > 1) {
    warning("indexing more than one element in ZIP archive", paste(i, collapse = ", "))
    ans[[1]]
  } else
    ans
}
}

# setOldClass("ZipArchive")

setClass("unzContentRef", contains = "RC++Reference",
          prototype = list(classes = "unzContent"))

setClass("unzInMemoryDataRef", contains = "RC++Reference",
          prototype = list(classes = "unzInMemoryData"))


setClass("unzFileRef", contains = "unzContentRef", prototype = list(classes = c("unzFile", "unzContent")))
setClass("unzMemoryRef", 
          representation(localRData = "unzInMemoryDataRef"),
	  contains = "unzContentRef",
          prototype = list(classes = c("unzMemory", "unzContent")))

setClass("ZipArchive", representation(classes = "character", elements = "character", info = "data.frame"),
               prototype = list(classes = "ZipArchive"))

setClass("ZipFileArchive", representation(readTime = "POSIXct"),
                           contains = c("character", "ZipArchive"),
                 prototype = prototype(readTime = as.POSIXct(NA)))

setClass("ZipMemoryArchive", contains = c("ZipArchive", "unzMemoryRef"),
               prototype = list(classes = c("ZipMemoryArchive", "ZipArchive", "unzMemory", "unzContent")))          



  # method for displaying the ZipArchive in an human-readable manner.
setMethod("show", "ZipArchive",
           function(object) {
             cat("Zip Archive:", object@.Data, "\n")
             show(object@elements)
           })



zipArchive =
function(filename, check = TRUE, class = if(is.raw(filename)) "ZipMemoryArchive" else "ZipFileArchive")
{
    time = structure(0, class = c("POSIXct", "POSIXt"))
    if(is.raw(filename)) {
      z = as(filename, 'unzMemoryRef')
      ans = new(class, ref = z@ref, localRData = z@localRData)
    } else {
      filename = path.expand(filename)
      if(check && !file.exists(filename))
        stop("file ", filename, " does not exist")

      filename = normalizePath(filename)
      ans = new(class, filename, readTime = time)
    }


   if(check) {
       if(is(ans, "ZipFileArchive"))
          ans@readTime = Sys.time()
       
       ans@info = getZipInfo(filename)
       ans@elements = ans@info[, "entry_name"] # rownames(ans@info)
   }

   ans
}

normalizePath =
function(path)
{
   nPath = if(getRversion() < "2.13.0")  utils::normalizePath else base::normalizePath
   gsub(".*//", "/", nPath(path))
}

setMethod("length", "ZipArchive",
#"length.ZipArchive" =
function(x)
 length(names(x))
)

setMethod("names", "ZipArchive",
#"names.ZipArchive" =
function(x)
 attr(x, "elements")
)


print.ZipArchive =
function(x, ...)
  print(as.character(x))

setMethod("[", c("ZipArchive", j = "missing"),
#"[.ZipArchive" =
  # ... allows password and mode.
  # i can be a character or a number
  # Need to implement as number.
function(x, i, j, ..., password = character(), mode = "", drop = TRUE)
{ 
  lapply(i, function(i)  getZipFileEntry(x, i, password, mode))
})

setMethod("$", "ZipArchive",
#"$.ZipArchive" =
function(x, name)
{
  getZipFileEntry(x, name)
})

setMethod("[", c("ZipArchive", i = "missing", j = "missing"),
  function(x, i, j, ..., password = character(), mode = "", drop = TRUE)  {
        # Should be able to do this quicker by reading them sequentially rather tha
        # starting over again at the beginning for each.
      readAllZipEntries(x, password = password, mode = mode)
# Slow way      structure(lapply(names(x), function(id) x[[id]]), names = names(x))
  }
)



setMethod("[[", c("ZipArchive", j = "missing"),
  # ... allows password and mode.
  # i can be a character or a number
  # Need to implement as number.
function(x, i, j, ..., password = character(), mode = "", last = TRUE)
{ 
  ans = getZipFileEntry(x, i, password, mode, info = x@info, last = last)

  if(!is.raw(ans) && length(ans) > 1) {
    warning("indexing more than one element in ZIP archive", paste(i, collapse = ", "))
    ans[[1]]
  } else
    ans
})



loadZip = readBinaryFile = 
function(filename)
{
  con = file(filename, "rb")
  on.exit(close(con))

  fs = file.info(filename)$size
  readBin(con, raw(fs), fs)
}  
