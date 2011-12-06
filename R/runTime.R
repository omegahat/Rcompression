setClass("RC++Reference",
          representation(ref = "externalptr",
                         classes = "character"))

setClass("ExternalArray",
            contains = "RC++Reference")

setClass("ExternalArrayWithLength",
            contains = "ExternalArray")

asReference =
function(x, type)
{
  if(!is(x, "RC++Reference"))
     stop("Not an RC++Reference")

    # Can check the type here.
  if(is.na(match(type,  x@classes)))
     stop("reference object does not correspond to target type ", type)

  x  
}

setMethod("$", "RC++Reference",
          function(x, name) {
            ..f = get(name, mode = "function")
            function(...)
               ..f(x, ...)
          })



# These are the generic methods for accessing an element
# in an external array.
# They can be overridden by auto-generated code
# with more specific  methods for new types of
# derived classes. 
# To use these

if(FALSE) {
setMethod("[[", c("ExternalArray", "numeric"),
          function(x, i, j, ...) {
            if(i < 1)
              stop("index for ", class(x), " must be 1 or more")
              # now go fetch.

            routine = ArrayAccessorElementRoutine(x)
            .Call(routine, x, as.integer(i))
          })


setMethod("[[", c("ExternalArrayWithLength", "numeric"),
          function(x, i, j, ...) {
            if(i < 1)
              stop("index for ", class(x), " must be 1 or more")

            if(i > length(x))
              stop("index to large for C/C++ array for ", class(x), ". Should be <= ", length(x))
            
            # go get it.
            routine = ArrayAccessorElementRoutine(x)
            .Call(routine, x, as.integer(i))            
          })
}

  #
  #
  #
setGeneric("ArrayAccessorElementRoutine",
           function(x)
             standardGeneric("ArrayAccessorElementRoutine")
          )
