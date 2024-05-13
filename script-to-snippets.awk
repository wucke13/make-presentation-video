#!/usr/bin/env -S awk -f

BEGIN {
  snippet_counter=0
  slide=1
}

# advance to the next snippet
function next_snippet_file(){
  snippet_counter++
  snippet_file="build/script-snippet-" snippet_counter ".txt"
  printf("") > snippet_file

  system("ln --force --relative --symbolic -- 'build/slide-" slide ".png' 'build/script-snippet-" snippet_counter "-slide.png'")
}

"---" == $1 && "---" == $3 {
  if ($2 ~/^slide=([0-9])+$/) slide = substr($2, 7) + 0
  next_snippet_file()

  # skipt this line
  next
}

# skip empty lines
/^\s*$/ { next }

{
  # ignore if no snippet began so far, print verbatim else
  if (snippet_counter == 0) next
  else print $0 >> snippet_file
}
