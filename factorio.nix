{ src,
  pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {}
}:

with {
  factorio-patched = pkgs.stdenv.mkDerivation {
    name = "factorio-patched";
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

    ${factorio-patched}/bin/x64/factorio --config "$DATA_DIR/config/config.ini" "$@"
  '';

  factorio-server = pkgs.writeShellScriptBin "factorio-server" ''
    usage() {
      echo "usage:"
      echo ""
      echo "  $0 <name> create    : create the server folders and default config"
      echo "  $0 <name> map-gen @ : generate a map for the server, using the config"
      echo "  $0 <name> start @   : start the server"
      echo ""
      echo "extra args (@) will be forwarded to the factorio executable."
      exit 1
    }

    if [ "$#" -lt 2 ]; then
      echo "error: invalid number of arguments"
      usage
    fi

    name=$1
    command=$2
    shift && shift

    ${factorio}/bin/factorio --version

    SERVER_DIR="$HOME/.factorio/servers/$name"

    case $command in
      create)
        echo "creating '$SERVER_DIR'"

        # create server directory structure
        mkdir -p $SERVER_DIR/config
        mkdir -p $SERVER_DIR/saves
        mkdir -p $SERVER_DIR/mods

        # copy default configs
        cat ${factorio-patched}/data/map-gen-settings.example.json > $SERVER_DIR/config/map-gen-settings.json
        cat ${factorio-patched}/data/map-settings.example.json > $SERVER_DIR/config/map-settings.json
        cat ${factorio-patched}/data/server-settings.example.json > $SERVER_DIR/config/server-settings.json
        ;;

      map-gen)
        echo "generating map in '$SERVER_DIR'"

        # generate a save, this is also when the map is generated
        ${factorio}/bin/factorio \
          --create $SERVER_DIR/saves/main.zip \
          --map-gen-settings $SERVER_DIR/config/map-gen-settings.json \
          --map-settings $SERVER_DIR/config/map-settings.json \
          "$@"
        ;;

      start)
        echo "starting '$SERVER_DIR'"

        # start the server
        ${factorio}/bin/factorio \
          --start-server $SERVER_DIR/saves/main.zip \
          --server-settings $SERVER_DIR/config/server-settings.json \
          "$@"
        ;;

      *)
        echo "error: unknown command '$command'"
        usage
        ;;
    esac
  '';
}
