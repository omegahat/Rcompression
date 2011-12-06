library(Rcompression)


if(FALSE) {
content = loadZip("inst/sampleData/Empty.docx")
d = zipArchive(content)
d[["word/document.xml"]]

# Equivalent, direct version
Rcompression:::getZipFileEntry(d, "word/document.xml")

ar = zipArchive("inst/sampleData/Empty.docx")
ar[["word/document.xml"]]
}







