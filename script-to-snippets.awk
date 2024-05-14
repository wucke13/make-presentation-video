#!/usr/bin/env -S awk -f

BEGIN {
  snippet_counter=0
  slide=1
}

# advance to the next snippet
function next_snippet_file(){
  snippet_counter++
  snippet_file="build/script-snippet-" snippet_counter ".txt"
  snippet_slide_file="build/script-snippet-" snippet_counter "-slide"
  printf("") > snippet_file
  printf("slide-" slide ".png") > snippet_slide_file
}

"---" == $1 && "---" == $3 {
  if ($2 ~/^slide=-?([0-9])+$/) slide = substr($2, 7) + 0
  if ($2 ~/^slide\+=-?([0-9])+$/) slide += substr($2, 8) + 0
  if ($2 ~/^slide\+\+$/) slide++
  if ($2 ~/^slide-=-?([0-9])+$/) slide -= substr($2, 8) + 0
  if ($2 ~/^slide--$/) slide--
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
