library(Rcompression)
docx = system.file("sampleData", "XML.docx", package = "Rcompression")
a = zipArchive(docx)

doc = a[["word/document.xml"]]

dir = tempdir()
system(paste("cd", dir, "; unzip -o", docx))

txt = paste(readLines(paste(dir, "word/document.xml", sep = .Platform$file.sep)), collapse = "\r\n")
txt == doc 




if(FALSE) {
info = getZipInfo(docx)

w = Rcompression:::getZipFileEntry(docx, "word/comments.xml")
x = info$"word/comments.xml"
y = info[[6]]
z = info[["comments.xml"]]  # matches more than one file

identical(w, x)
w == x
w == x && w == y
substring(w, 1, nchar(w)) == substring(x, 1, nchar(x))


Encoding(w) =  "UTF-8"
Encoding(x) =  "UTF-8"
w == x

Encoding(w) =  "latin-1"
Encoding(x) =  "latin-1"
w == x


  # The accessor methods for the ZipArchiveDataFrame are not exported or active
  # at present.
info[["comments.xml$"]]  # matches only one file because of the regular expression $

info["comments.xml"]  # matches more than one file

# Previous one returns a list of length 1 whch contains the 2 entries.
#  lapply in [ and in getZipFileEntry.

info[c(2, 6)] 
}

