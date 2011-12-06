library(Rcompression)

readCompressedFile = 
function(filename = system.file("sampleData", "NAMESPACE.gz", package = "Rcompression"))
{  
 con = file(filename, "rb")
 fs = file.info(filename)$size
 content  = readBin(con, raw(fs), fs)
 close(con)

 content
}

gz = readCompressedFile()
gunzip(gz, 10000)

bz = readCompressedFile(system.file("sampleData", "NAMESPACE.bz2", package = "Rcompression"))
bunzip2(bz)
