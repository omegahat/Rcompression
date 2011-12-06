getZipComment =
function(filename)
{
   if(is(filename, 'unzContentRef')) {
      h = filename
   } else {  
      h = as(filename, 'unzFileRef')   
      on.exit(unzClose(h))
   }

   .Call("R_unzGetGlobalComment", h)
}


