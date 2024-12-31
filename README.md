# infra
## ./home
- [home-manager](https://github.com/nix-community/home-manager) configuration files
- foot, tmux, and zsh are configured in Nix
- nvim, rofi, sway, waybar are configured in their own literature and symlinked to $XDG_CONFIG_HOME with home-manager

## ./hosts
- [`hosts/common.nix`](hosts/common.nix): configuration that makes sense on all computers
- [`hosts/zsh.nix`](hosts/zsh.nix): for computers that have the power to run zsh
### ./hosts/ytnix
- personal laptop
- a single [`default.nix`](hosts/ytnix/default.nix) that could be modularized but works for now

### ./hosts/chunk
- the overworked server with 5% SLA
- very short and concise [`default.nix`](hosts/chunk/default.nix)
- services organized in their modules
- some services run through `virtualisation.oci-containers`:
    - [immich](hosts/chunk/immich.nix)
    - [conduwuit](hosts/chunk/conduwuit.nix)

### ./hosts/titan
- got this cause chunk would go down way too often :(
- hosted on azure for "reliability"
- runs:
    - [ghost](hosts/titan/ghost.nix) (through `virtualisation.oci-containers`)
    - [uptime-kuma](hosts/titan/uptime-kuma.nix)
    - [ntfy-sh](hosts/titan/ntfy.nix)

## ./secrets
- secrets
- see [`.sops.yaml`](.sops.yaml) for who privy to what

## backups
- hourly borgbackup to [rsync.net](https://rsync.net)
- see [modules/backup](modules/backup.nix)

## monitoring
- [status.cything.io](https://status.cything.io/): uptime kuma (reliable)
- [grafana.cything.io](https://grafana.cything.io/): some real-time metrics here; unlike the status page this will go kaput often
