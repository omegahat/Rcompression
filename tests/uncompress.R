library(Rcompression)

x = "A string to compress"
g = compress(x)

val = uncompress(g, 5, resizeBy = 1.00001)

