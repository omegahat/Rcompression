library(Rcompression)
x = I(c(a = "ABC", b = "DEF", c = "GHIJKLML"))
comments = paste("Long comments about the different elements", 1:length(x))

  # create random comments with variable length.
comments = sapply(rpois(length(x), 200),
                   function(len)
                    paste(sample(c(letters, LETTERS), len, replace = TRUE), collapse = ""))

zip("foo.zip", x, comments = comments, append = FALSE, globalComment = "A global comment for my zip file")
z = zipArchive("foo.zip")
info = getZipInfo(z, comment = TRUE)

com = getZipComment(z)

all(as.character(info[,"comment"]) == comments)
# Compare lengths.
#  all(nchar(as.character(info[,"comment"])) == nchar(comments))


zip("bar.zip", x,  append = FALSE)
z = zipArchive("bar.zip")
all(z@info[,"comment"] == "")

 # Some present, some not.
comments =  c("", "a comment", "")
zip("bar.zip", x,  append = FALSE, comments = comments)
z = zipArchive("bar.zip")
all(z@info[,"comment"] == comments)


