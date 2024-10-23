{ src,
  pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {}
}:

with {
  factorio-patched = pkgs.stdenv.mkDerivation {
    name = "factorio-patched2";
    inherit src;

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

    # On the first run, create DATA_DIR, and install the default config.
    if [ ! -d "$DATA_DIR" ]; then
      mkdir -p "$DATA_DIR/config"
      cat ${./config.ini} > "$DATA_DIR/config/config.ini"
      sed -i "s|\$DATA_DIR|$DATA_DIR|g" "$DATA_DIR/config/config.ini"
    fi

    ${factorio-patched}/bin/x64/factorio --config "$DATA_DIR/config/config.ini"
  '';
}
