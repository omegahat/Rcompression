library(Rcompression)

filename = system.file("sampleData", "OmegahatXSL_0.2-0.tar.gz", package = "Rcompression")

i = tarInfo(filename)
files = i$file[!( i$type %in% "DIRTYPE")]

raws = tarExtract(filename, files)
tarByteCount = sapply(raws, function(x) nchar(rawToChar(x)))


system.file("tar zxf OmegahatXSL_0.2-0.tar.gz -C /tmp")
info = file.info(list.files("/tmp/OmegahatXSL", recursive = TRUE, full.names = TRUE))
rownames(info) = gsub("/tmp/", "", rownames(info))

#

all(tarByteCount[ rownames(info) ] == info$size)




#####################################################################
# From tarExtract.Rd
#

  filename = system.file("sampleData", "OmegahatXSL_0.2-0.tar.gz", package = "Rcompression")
  i = tarInfo(filename)
  files = i$file[!( i$type %in% "DIRTYPE")]

  countLines =
     function(contents, fileName = "", verbose = FALSE) {

                  # if (verbose) cat(fileName, "\n")
        numLines = length(strsplit(rawToChar(contents), "\\\n")[[1]])
        lineCounts[fileName] <<- numLines
        numLines
     }


  lineCounts = numeric()
  time1 = system.time(tarExtract(filename, files,  countLines))
  a = lineCounts
  lineCounts = numeric()

  time2 = system.time(zz <- tarExtract(filename, files,  convert = countLines, verbose = FALSE))
  all(zz[names(a)] == a)


######################################
#
# Explore the effect on timings of using different size work buffers.
#
  filename = system.file("sampleData", "OmegahatXSL_0.2-0.tar.gz", package = "Rcompression")
  i = tarInfo(filename)
  files = i$file[!( i$type %in% "DIRTYPE")]

  a = system.time(replicate(10, invisible(tarExtract(filename, files))))

             # Now we use a work buffer that will not need to be expanded.
  b = system.time(replicate(10, invisible(tarExtract(filename, files, workBuf = max(i$size)))))
  a["elapsed"]/b["elapsed"]

 # The result is a factor of 12.84
