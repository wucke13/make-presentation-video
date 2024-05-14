#!/usr/bin/env -S awk -f

BEGIN {
  snippet_counter = 0
}

# count snippet delimiter lines
"---" == $1 && "---" == $3 {
  print "build/script-snippet-" ++snipper_counter ".txt"
}

# skip all but snippet delimiter lines
{
  next
}
