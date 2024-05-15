{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

pkgs.mkShellNoCC {
  nativeBuildInputs = with pkgs; [
    espeak-ng # run-time dependency of tts
    ffmpeg-full # handles audio/video encoding
    findutils # finds files
    gawk # text parsing
    gnumake # make flavour
    mupdf # to conver PDF to PNG
    tts # text to speech engine
  ];
}
