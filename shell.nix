let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/95d1b593aab60766964d22d8ec0b0847678bdee2";
  pkgs = import nixpkgs { config = { allowUnfree = true; }; overlays = [ ]; };
in
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
