{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

pkgs.mkShellNoCC {
  nativeBuildInputs = with pkgs; [
    gawk # text parsing
    ffmpeg-full # handles audio/video encoding
    findutils # finds files
    mupdf # to conver PDF to PNG
    tts # text to speech engine
    gnumake # make flavour
  ];
}
