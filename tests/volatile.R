library(Rcompression)
f = system.file("sampleData", "MyZip.zip", package = "Rcompression")
p = zipArchive(f, const = FALSE)
names(p)
o = zipArchive(f, const = TRUE)
names(o)

stopifnot(all(names(o) == names(p)))

id = paste(sample(1:9, rbinom(1, 10, .5), replace = TRUE), collapse = "")
p[[id]] = I("random text")

stopifnot(id %in% names(p))

stopifnot(!( id %in% names(o)))

