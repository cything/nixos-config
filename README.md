# infra
## ./home
- home-manager configuration files
- foot, tmux, and zsh are configured in Nix
- nvim, rofi, sway, waybar are configured in their own literature and symlinked to $XDG_CONFIG_HOME with home-manager

## ./hosts
- [`common.nix`](hosts/common.nix): configuration that makes sense on all computers
### ./hosts/ytnix
- personal laptop
- a single [`default.nix`](hosts/ytnix/default.nix) that could be modularized but works for now

### ./hosts/chunk
- the overworked server with 5% SLA
- very short and concise [`default.nix`](hosts/chunk/default.nix)
- `.nix` modules for each service
- some services run through `virtualisation.oci-containers`:
    - [immich](hosts/chunk/immich.nix)
    - [ghost](hosts/chunk/ghost.nix)
    - [conduit](hosts/chunk/conduit.nix)

## ./secrets
- secrets
- see [`.sops.yaml`](.sops.yaml) for who privy to what

## monitoring
- [status.cything.io](https://status.cything.io/): uptime kuma, hosted on azure for resiliency<sup>TM</sup>
- [grafana.cything.io](https://grafana.cything.io/): some metrics real-time metrics here; unlike the status page this will go kaput often