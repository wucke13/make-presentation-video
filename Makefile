# Programs to be used
FFMPEG          ?= ffmpeg
MUTOOL          ?= mutool
TTS             ?= tts

# Inputs
SCRIPT          ?= script.txt
PDF             ?= slides.pdf
RESOLUTION_X    ?= 1920
RESOLUTION_Y    ?= 1080

# Configuration
TTS_EXTRA_FLAGS ?= --model_name tts_models/en/ljspeech/vits

# Internal build logics
SCRIPT_TEXT_SNIPPETS  := $(shell scripts/enumerate-snippets.awk $(SCRIPT))
SCRIPT_AUDIO_SNIPPETS := $(SCRIPT_TEXT_SNIPPETS:.txt=.wav)

NUMBER_OF_PAGES       := $(shell $(MUTOOL) show $(PDF) trailer/Root/Pages/Count)
PNGS                  := $(shell seq --format 'build/slide-%g.png' 1 $(NUMBER_OF_PAGES))


# declare which rules do not actualy create an artifact
.PHONY: all clean


# remove internal built-in rules
.SUFFIXES:

all: build/output.mp4
	@echo "done, final output is"
	@ls --human-readable --si --size -- build/output.mp4

clean:
	@rm --force --recursive -- build


# derive timeline from the audio snippets
build/audio-timeline.txt build/video-timeline.txt &: $(SCRIPT) $(SCRIPT_AUDIO_SNIPPETS)
	./scripts/make-timeline.sh $<

# concatenate audio snippets into one
build/audio.wav: build/audio-timeline.txt $(SCRIPT_AUDIO_SNIPPETS)
	$(FFMPEG) -y -f concat -i $< $@

# concatenate video snippets into one
build/video.mp4: build/video-timeline.txt $(PNGS)
	$(FFMPEG) -y -f concat -i $< -filter:v fps=5 -movflags +faststart $@

# merge audio and video into final output.mp4
build/output.mp4: build/audio.wav build/video.mp4
	$(FFMPEG) -y -i build/video.mp4 -i build/audio.wav -c:v copy -c:a aac $@

# render slides PDF into PNGs, one per page
$(PNGS) &: $(PDF)
	@mkdir --parent -- $(@D)
	$(MUTOOL) convert -o build/slide-%d.png -F png -O width=$(RESOLUTION_X),height=$(RESOLUTION_Y) $<

# extract text snippets from script
$(SCRIPT_TEXT_SNIPPETS) &: $(SCRIPT)
	@mkdir --parent -- $(@D)
	./scripts/script-to-snippets.awk $<

# magic rule to convert text to sound
%.wav: %.txt
	$(TTS) $(TTS_EXTRA_FLAGS) --text "$$(< $< )" --out_path $@
