library(Rcompression)
content = list( myFile = I("This is raw text"), otherFile = I(paste(letters, collapse = "\n")))
zip("asis.zip", content, append = FALSE)

z = zipArchive("asis.zip")
z$foo = I("some text: foo")
z$bar = I("some other text: bar")
z@elements

nz = rmZipEntries(z, "foo")
nz@elements
nz$bar



a = zave(x = 1:10, y = rnorm(10), z = letters, w = mtcars, file = "zz.Rdz")
a = rmZipEntries(a, "y")
a@elements
a$x
a$z

a = rmZipEntries(a, c("x", "w"))
a$z

