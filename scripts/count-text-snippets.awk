#!/usr/bin/env -S awk -f

# count snippet delimiter lines
"---" == $1 && "---" == $3 {
  snippet_counter++
  next
}

# skip all but snippet delimiter lines
{
  next
}

# print the number in the end
END {
  print snippet_counter 
}
