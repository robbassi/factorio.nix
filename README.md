## Usage

You'll need to supply the Factorio tarball, you can get this from
https://www.factorio.com/download.

### Build
```bash
$ nix-build factorio.nix -A factorio --arg src ./factorio-space-age_linux_2.0.8.tar.xz
$ ./result/bin/factorio
```
### Install
```bash
$ nix-env -i -f factorio.nix -A factorio --arg src ./factorio-space-age_linux_2.0.8.tar.xz
$ factorio
```

## Notes

On the first run, the wrapper script creates `$HOME/.factorio` to store all the
mutable game data. This is also where the config is stored.
