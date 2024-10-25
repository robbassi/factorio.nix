## Usage

You'll need to supply the Factorio tarball, you can get this from
https://www.factorio.com/download.

```bash
$ nix-env -i -f factorio.nix -A factorio --arg src ./factorio-space-age_linux_2.0.10.tar.xz
$ factorio
```
On the first run, the wrapper script creates `$HOME/.factorio` to store the config and mutable game data.

### Server

Install the server with:
```bash
$ nix-env -i -f factorio.nix -A factorio-server --arg src ./factorio-space-age_linux_2.0.10.tar.xz
```
Or on a headless machine:
```bash
$ nix-env -i -f factorio.nix -A factorio-server --arg src ./factorio-headless_linux_2.0.10.tar.xz
```

Create the server folder structure, and default configuration.
```bash
$ factorio-server my-server-1 create

Version: 2.0.10 (build 79578, linux64, headless)
Version: 64
Map input version: 1.0.0-0
Map output version: 2.0.10-1
Creating '/home/user/.factorio/servers/my-server-1'
```

You can modify the configs, and/or add mods in this directory:
```bash
$ tree ~/.factorio/servers/my-server-1

my-server-1
|-- config
|   |-- map-gen-settings.json
|   |-- map-settings.json
|   `-- server-settings.json
|-- mods
`-- saves
```

Generate the map and initial save using the configs defined above:
```bash
$ factorio-server my-server-1 map-gen
```

Launch the server:
```bash
$ factorio-server my-server-1 start --port 12345
```
