# [No] The problem appears to be that in unzGoToNextFile
# we are at the end of the list of files and so 
# return at line 763. 
#  Turns out to be the same for reading from a file.
library(Rcompression)

f = system.file("sampleData", "Empty.docx", package = "Rcompression")

if(file.exists(f)) {
 w = zipArchive(f)
 w[["word/styles.xml"]]

cat("Using in memory archive\n")
 a = zipArchive(loadZip(f))
 a[["word/styles.xml"]]


} else
 cat("No such file Empty.docx in Rcompression")
