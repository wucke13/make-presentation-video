#!/usr/bin/env bash

set -e

rm --force -- build/{audio,video}-timeline.txt

find build -name 'script-snippet-*.wav' -print0 | sort --numeric-sort --zero-terminated |
while IFS= read -r -d '' file_path; do
	DURATION=$(ffprobe -i "$file_path" -show_entries format=duration -v quiet -of csv="p=0")

	# ffmpeg expects just the filename, as the files are in the same folder as the timeline file
	FILE="${file_path##build/}"

	# generate audio-timeline
	cat <<- EOF >> build/audio-timeline.txt
	file '$FILE'
	duration $DURATION
	EOF

	# genreate video-timeline
	cat <<- EOF >> build/video-timeline.txt
	file '$(< "build/${FILE%%.wav}-slide")'
	duration $DURATION
	EOF

done

# BUG this doens't work, thing is running in a subshell.
# Somehow the last slide is ignored by ffmpeg, lets add a zero duration last slide
tail --lines 2 build/video-timeline.txt | sed 's/^duration.*/duration 0/' >> build/video-timeline.txt 
