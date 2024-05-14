# Programs to be used
FFMPEG          ?= ffmpeg
MUTOOL          ?= mutool
TTS             ?= tts

SCRIPT          ?= script.txt
PDF             ?= slides.pdf
RESOLUTION_X    ?= 1920
RESOLUTION_Y    ?= 1080


TTS_EXTRA_FLAGS := --model_name tts_models/en/ljspeech/vits

SCRIPT_SNIPPETS := $(shell awk 'BEGIN {snippet_counter = 0} "---" == $$1 && "---" == $$3 { print "build/script-snippet-" ++snipper_counter ".txt" } { next }' $(SCRIPT))

NUMBER_OF_PAGES := $(shell $(MUTOOL) show $(PDF) trailer/Root/Pages/Count) 


.PHONY: all clean dirs audio png timeline video

all: video

clean:
	rm --force --recursive -- build

dirs:
	mkdir --parent -- build

audio: txt $(SCRIPT_SNIPPETS:txt=wav)

png: $(PDF) dirs #$(shell seq --format 'build/slide-%g.png' 1 $(NUMBER_OF_PAGES))
	$(MUTOOL) convert -o build/slide-%d.png -F png -O width=$(RESOLUTION_X),height=$(RESOLUTION_Y) $(PDF)

txt: $(SCRIPT) dirs
	./script-to-snippets.awk $<

timeline: audio
	./make-timeline.sh

video: audio png timeline
	# concat audio
	$(FFMPEG) -y -f concat -i build/audio-timeline.txt build/audio.wav

	# concat video
	$(FFMPEG) -y -f concat -i build/video-timeline.txt -filter:v fps=5 -movflags +faststart build/video.mp4

	# merge audio and video
	$(FFMPEG) -y -i build/video.mp4 -i build/audio.wav -c:v copy -c:a aac build/output.mp4


# magic rule to convert txt to sound
%.wav: txt
	$(TTS) $(TTS_EXTRA_FLAGS) --text "$$(< $(@:.wav=.txt) )" --out_path $@
