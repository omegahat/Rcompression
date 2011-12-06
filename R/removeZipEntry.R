rmZipEntries =
function(archive, entries)
{
  els = archive[ , mode = "raw"]
  if(is.character(entries))
    i = match(entries, names(els))
  else
    i = entries

   # Need to restore comments, etc.
  # For RdzArchive, rebuild the toc by removing the relevant rows.
  #  For RdzArchive, we want to call zave(), not zip().
  #
  # We could pass the modified @info object to zipArchive
  
  if(zip(as(archive, "character"), els[ -i ], append = FALSE))
     zipArchive(archive, class = class(archive))
  else
     stop("should have stopped in zip!")
}

