library(Rcompression)
content = list( myFile = I("This is raw text"), otherFile = I(paste(letters, collapse = "\n")))
zip("asis.zip", content, append = FALSE)

z = zipArchive("asis.zip")
z$foo = I("some text: foo")
z$bar = I("some other text: bar")
z@elements
z@info
z[["foo"]] = I("replacement for foo")
z@elements
z$foo

 # replace and add one in a single operation
z = updateArchiveFiles(z, list(new = I("A new entry"), foo = I("a different version of foo")))
z@elements
z@info

z[ c("ab", "cd")] = list(I("A new entry"), I("a different version of foo"))



z = zave(x = 1:10, y = letters, file = "zz.Rdz", append = FALSE)
z@elements
z$.toc

z$x
z$w = LETTERS # toc is now out of date
z$x = c(1, 2, 3)

z[c("x", "a")] = list(2, c("ab", "cde"))


