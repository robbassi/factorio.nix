{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {} }:

with {
  inherit pkgs;

  factorio = pkgs.stdenv.mkDerivation rec {
    name = "factorio-patched";
    src = ./factorio-space-age_linux_2.0.8.tar.xz;
    installPhase = ''
      mkdir -p $out
      cp -r ./* $out
    '';
  };
};

pkgs.mkShell rec {
  buildInputs = 
    (with pkgs; [ 
      SDL2 
      SDL2_image 
      SDL2_ttf 
      libGL
      pipewire
    ]) ++ (with pkgs.xorg; [
      libX11
      libXcursor
      libXrandr
    ]);
  shellHook = ''
    mkdir -p /home/rob/src/factorio/run
    cd /home/rob/src/factorio/run
    cp -r ${factorio}/* .
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH"
    ./bin/x64/factorio && exit
  '';
}
