# Programs to be used
FFMPEG             ?= ffmpeg
MUTOOL             ?= mutool
TTS                ?= tts

# Inputs
SCRIPT             ?= script.txt
PDF                ?= slides.pdf
RESOLUTION_X       ?= 1920
RESOLUTION_Y       ?= 1080

# Configuration
TTS_EXTRA_FLAGS    ?= --model_name tts_models/en/ljspeech/vits
FFMPEG_EXTRA_FLAGS ?= -hide_banner -loglevel info
FFMPEG_AUDIO_FLAGS ?=
FFMPEG_VIDEO_FLAGS ?= -pix_fmt yuv420p -filter:v fps=5 -movflags +faststart

# Internal build logics
NUMBER_OF_SNIPPETS    := $(shell scripts/count-text-snippets.awk $(SCRIPT))
SCRIPT_TEXT_SNIPPETS  := $(shell seq --format 'build/script-snippet-%g.txt' 1 $(NUMBER_OF_SNIPPETS))
SCRIPT_AUDIO_SNIPPETS := $(SCRIPT_TEXT_SNIPPETS:.txt=.wav)
FFMPEG_FLAGS          := -y $(FFMPEG_EXTRA_FLAGS)

NUMBER_OF_PAGES       := $(shell $(MUTOOL) show $(PDF) trailer/Root/Pages/Count)
PNGS                  := $(shell seq --format 'build/slide-%g.png' 1 $(NUMBER_OF_PAGES))

# disable builtin rules
MAKEFLAGS             += --no-builtin-rules

# declare which rules do not actualy create an artifact
.PHONY: all clean


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
	$(FFMPEG) -f concat -i $< $(FFMPEG_FLAGS) $(FFMPEG_AUDIO_FLAGS) $@

# concatenate video snippets into one
build/video.mp4: build/video-timeline.txt $(PNGS)
	$(FFMPEG) -f concat -i $< $(FFMPEG_FLAGS) $(FFMPEG_VIDEO_FLAGS) $@

# merge audio and video into final output.mp4
build/output.mp4: build/audio.wav build/video.mp4
	$(FFMPEG) $(addprefix -i , $^) $(FFMPEG_FLAGS) -codec:v copy -codec:a aac $@

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
