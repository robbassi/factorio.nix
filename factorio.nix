{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {} }:

with {
  factorio-patched = pkgs.stdenv.mkDerivation rec {
    name = "factorio-patched2";
    src = ./factorio-space-age_linux_2.0.8.tar.xz;

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out
      cp -r ./* $out
    '';

    postFixup = ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $out/bin/x64/factorio
    '';
  };
};

rec {
  libs = (with pkgs; [ 
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

  factorio = pkgs.writeShellScriptBin "factorio" ''
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath libs}:$LD_LIBRARY_PATH"

    DATA_DIR="$HOME/.factorio"

    # first run, create user dir for config + write data
    if [ ! -d "$DATA_DIR" ]; then
      mkdir -p "$DATA_DIR/config"
      cat << EOF > "$DATA_DIR/config/config.ini"
; version=11
[path]
read-data=__PATH__executable__/../../data
write-data=$DATA_DIR

[general]
locale=auto

[other]
[interface]
[input]
[controls]
[controller]
[sound]
[map-view]
[debug]
[multiplayer-lobby]
[graphics]
EOF
    fi

    ${factorio-patched}/bin/x64/factorio --config "$DATA_DIR/config/config.ini" && exit
  '';
}
