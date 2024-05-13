#!/usr/bin/env bash

rm --force -- build/{audio,video}-timeline.txt

find "$(pwd)" -name '*.wav' -print0 | sort --zero-terminated |
while IFS= read -r -d '' file; do
	DURATION=$(ffprobe -i "$file" -show_entries format=duration -v quiet -of csv="p=0")

	# generate audio-timeline
	cat <<- EOF >> build/audio-timeline.txt
	file '$file'
	duration $DURATION
	EOF

	# genreate video-timeline
	cat <<- EOF >> build/video-timeline.txt
	file '${file%%.wav}-slide.png'
	duration $DURATION
	EOF

done

# concat audio
ffmpeg -y -f concat -safe 0 -i build/audio-timeline.txt build/audio.wav

# concat video
ffmpeg -y -f concat -safe 0 -i build/video-timeline.txt -filter:v fps=5 -movflags +faststart build/video.mp4

# merge audio and video
ffmpeg -y -i build/video.mp4 -i build/audio.wav -c:v copy -c:a aac build/output.mp4
