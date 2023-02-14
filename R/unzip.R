#library(Rcompression)

#library(RGCCTranslationUnit)

setClass("voidRef", contains = "RC++Reference",
          prototype = list(classes = "void"))


unzRef = 
function(filename)
{
   as(filename, if(is.raw(filename)) 'unzMemoryRef' else 'unzFileRef')
}

setAs('raw', 'unzMemoryRef',
       function(from) {
          .Call("R_unzOpenRaw", from, "")
       })

setAs('character', 'unzFileRef',
       function(from) {
         if(!file.exists(from))
          stop("Cannot find file ", from)
  
         unzOpen(path.expand(from))
       })


# order is important.
setClass('tm_unz', representation( 'tm_sec' = 'numeric', 'tm_min' = 'numeric', 'tm_hour' = 'numeric', 'tm_mday' = 'numeric', 'tm_mon' = 'numeric', 'tm_year' = 'numeric' )) 
setClass('tm_unzRef',contains = 'RC++Reference', prototype = list(classes = 'tm_unz')) 

setClass('unz_file_info', representation( 'version' = 'numeric', 'version_needed' = 'numeric', 'flag' = 'numeric', 'compression_method' = 'numeric', 'dosDate' = 'numeric', 'crc' = 'numeric', 'compressed_size' = 'numeric', 'uncompressed_size' = 'numeric', 'size_filename' = 'numeric', 'size_file_extra' = 'numeric', 'size_file_comment' = 'numeric', 'disk_num_start' = 'numeric', 'internal_fa' = 'numeric', 'external_fa' = 'numeric', 'tmu_date' = 'tm_unz' )) 
setClass('unz_file_infoRef',contains = 'RC++Reference', prototype = list(classes = 'unz_file_info')) 

setClass('unz_global_info', representation( 'number_entry' = 'numeric', 'size_comment' = 'numeric' )) 
setClass('unz_global_infoRef',contains = 'RC++Reference', prototype = list(classes = 'unz_global_info')) 




unzOpen <-
function( path )  
 UseMethod("unzOpen")

unzOpen.ZipFileArchive =
function(path)
{
     path = as.character( path )
    .Call('R_unzOpen', path)
}

unzOpen.character =
function(path)
{
    .Call('R_unzOpen', path)
}


unzOpen.ZipMemoryArchive =
function(path)
{
    .Call('R_unzMemoryRef_reset', path@localRData, -1L)
    .Call('R_unzGoToFirstFile', path)
    path
}


unzClose <-
function( file ) 
  UseMethod("unzClose")
 
unzClose.ZipFileArchive <-
function( file ) { 
     file = as(file, 'unzContentRef')
    .Call('R_unzClose', file)
}

unzClose.unzFileRef <-
function( file ) { 
     file = as(file, 'unzContentRef')
    .Call('R_unzClose', file)
}


unzClose.ZipMemoryArchive <-
function( file ) { 
    .Call('R_unzMemoryRef_reset', file@localRData, 0L) # or -1L
    file
}



unzGoToFirstFile <-
function( file ) { 
     file = as(file, 'unzContentRef')
    .Call('R_unzGoToFirstFile', file)
}
 
unzGoToNextFile <-
function( file ) 
{ 
     file = as(file, 'unzContentRef')
    .Call('R_unzGoToNextFile', file)
}
 

 
unzGetGlobalInfo <-
function( file ) { 
     file = as(file, 'unzContentRef')
    .Call('R_unzGetGlobalInfo', file)
}

unzGetCurrentFileInfo <-
function( file, szFileName, fileNameBufferSize, extraField, extraFieldBufferSize, szComment, commentBufferSize ) { 
     file = as(file, 'unzContentRef')
     szFileName = as.character( szFileName )
     fileNameBufferSize = as.integer( fileNameBufferSize )
     extraField = as.raw( extraField )
     extraFieldBufferSize = as.integer( extraFieldBufferSize )
     szComment = as.character( szComment )
     commentBufferSize = as.integer( commentBufferSize )
    .Call('R_unzGetCurrentFileInfo', file, szFileName, fileNameBufferSize, extraField, extraFieldBufferSize, szComment, commentBufferSize)
}





