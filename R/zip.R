setAs("ZipFileArchive", "unzFileRef",
       function(from)
           as(as(from, "character"), "unzFileRef"))

# Corresponds to enum in C code to identify the type of content
# of an element in the list() we pass to zip.
ContentTypes = c(FILENAME = 1L, AS_IS = 2L, RAW_CONTENT = 2L)

zip = simpleZip =
  #
  # time should be a POSIXct vector.
  #
function(zipfile, files = NULL, append = file.exists(zipfile),
          compression_level = 9, altNames = names(files),
           time = Sys.time(), comments = character(),
          globalComment = character())
{
  zipfile = as.character(zipfile)
  
  if(length(files) == 0) {
    files = list.files()
    info = file.info(files)
    files = files[!info$isdir]
  }
  if(is.character(files)) {
    if(!is(files, "AsIs"))
       files = structure(path.expand(files), names = names(files))
  } else {
    w = sapply(files, function(x) is.character(x) && !is(x, "AsIs"))
    files[w] = lapply(files[w], path.expand)
  }

   if(length(altNames) == 0)
       altNames = files

  
  if(length(files) == 0)
     stop("No files to add to zip file")

  if(is.character(files)) {
    isAsIs = is(files, "AsIs")
    files = split(files, seq(along = files))
    if(isAsIs) {
       files = lapply(files, function(x) I(x))
       types =  rep(1L, length(files))       
    } else
        types =  rep(0L, length(files))
  } else {
     types = sapply(files, class)
     types = match(types, c("character", "AsIs", "raw")) - 1L

     if(any(is.na(types))) {
        stop("Cannot serialize ", paste(names(files)[is.na(types)], collapse = ", "), " to a zip entry because its type is not a file name, AsIs text or raw.")
     }
  }

     # Check if all entries have a name. It is the regular files that
     # may not and that are okay.
   check = altNames == ""
   if(any(check)) {
      if(!all(types[check] == 0L))
         stop("Cannot have anonymous/un-named entries in a zip archive")
      altNames[check] = unlist(files[check])
   }

  if(any(is.na(time)))
    time[is.na(time)] = Sys.time()
  if(!inherits(time, "POSIXct"))
     class(time) = c("POSIXt", "POSIXct")
  
  time = as.POSIXlt(rep(time, length = length(files)))

  if(length(comments))
    comments = rep(as.character(comments), length = length(files))
  
  .Call("R_createZip", zipfile, files, as.character(altNames), as.integer(compression_level),
               as.logical(append), types, time, comments, as.character(globalComment))
}
