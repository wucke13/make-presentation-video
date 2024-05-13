# About

This is my dirty little stunt to fully automate the flow of creating presentation videos.
Its raw, its not safe (shell injection ?!) and its slow.
But, it's good enough for now :smile:.

# How does it work?

The user of this tool provides two inputs:

- `slides.pdf`: A slide deck, in PDF format
- `script.txt`: A script, to be spoken during the slides

Provided with this input, roughly the following happens:

1. The script is split into text snippets
2. The PDF is rendered to PNG images
3. Each snippet is (sym-)linked to its corresponding page in the slides
4. Each snippet is spoken by tts into an audio file
5. All audio files are concatenated into one audio file
6. The PNGs are concatenated into one video
7. The final video is assembled from the outputs of step 5. and step 6.

The script is expected to be in the following format:

```
--- slide=1 ---

I got something to say about this slide, uhm. Its great! Yeah, uhm. Thats it.

--- slide=2 ---

More greatness! Ah no, forgot.
There was something important on the first slide, let's quickly jump back.

--- slide=1 ---

There we go. The end.
```

# Resources

- []
- [Concatenating images to a video in ffmpeg](https://trac.ffmpeg.org/wiki/Concatenate)
