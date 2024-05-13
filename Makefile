# Programs to be used
FFMPEG          ?= ffmpeg
GS              ?= gs
TTS             ?= tts

SCRIPT          ?= script.txt
PDF             ?= slides.pdf
RESOLUTION      ?= 1920x1080


# -r304.75
GS_EXTRA_FLAGS  := -dNOPAUSE -r300 \
	-sDEVICE=png16m -dBATCH \
	-dTextAlphaBits=4 -dGraphicAlphaBits=1

TTS_EXTRA_FLAGS := --model_name tts_models/en/ljspeech/vits

SCRIPT_SNIPPETS := $(shell awk 'BEGIN {snippet_counter = 0} "---" == $$1 && "---" == $$3 { print "build/script-snippet-" ++snipper_counter ".txt" } { next }' script.txt)


.PHONY: all audio clean dirs png video

all: video

clean:
	rm --force --recursive -- build

dirs:
	mkdir --parent -- build

png: $(PDF) dirs
	$(GS) $(GS_EXTRA_FLAGS) -sOutputFile=build/slide-%d.png $<

txt: $(SCRIPT) dirs
	./script-to-snippets.awk $<

audio: txt $(SCRIPT_SNIPPETS:txt=wav)

video: audio png
	./make-video.sh


# magic rule to convert txt to sound
%.wav: %.txt txt
	$(TTS) $(TTS_EXTRA_FLAGS) --text "$$(<$<)" --out_path $@
