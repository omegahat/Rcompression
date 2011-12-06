library(Rcompression)
filename = system.file("sampleData", "OmegahatXSL_0.2-0.tar.bz2", package = "Rcompression")

# Read the contents of the file, uncompressing on the way.
f = bzfile(filename, "rb")
data = readBin(f, "raw", 1000000)
close(f)

 # Names of the files we will extract.
targetFiles = c("OmegahatXSL/XSL/env.xsl", "OmegahatXSL/XSL/Todo.xsl")

raws = tarExtract(data, targetFiles, convert = rawToChar)

#  Read from the equivalent .gz file
Files = tarExtract(gsub("\\.bz2$", "\\.gz", filename), targetFiles, convert = rawToChar)

 # Check the contents of the two sets of files from the bz2 and gz are the same.
print(identical(raws, Files))

 # Now extract the files to /tmp and then read them directly (rather than from the archive)
dir = tempdir()
if(.Platform$OS.type == "windows")
  dir = gsub("\\\\", "/", dir)

cmd = paste("tar -C", dir, "-jxf", filename, paste(targetFiles, collapse = " "))
print(system(cmd))
if(system(cmd) == 0) {
  truth = sapply(targetFiles, function(x) paste(readLines(paste(dir, x, sep = .Platform$file.sep)), collapse = "\n"))

# raws has an additional new line, at least on my MacbookPro and Linux box.
if(!identical(truth, raws)) {
 n = t(sapply(1:length(truth),
          function(i)
             c(nchar(truth[[i]]), nchar(raws[[i]]))))
 rownames(n) = targetFiles
 print(n)
}
}

info = tarInfo(data)

out = system(paste("tar jtf", filename), intern = TRUE)

all(info$file == out)

