{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../common.nix
    ../zsh.nix
    ./hardware-configuration.nix
    ./backup.nix
    ./rclone.nix
    ./postgres.nix
    ./hedgedoc.nix
    ./miniflux.nix
    ./redlib.nix
    ./vaultwarden.nix
    ./grafana.nix
    ./conduwuit.nix
    ./immich.nix
    ./element.nix
    ./attic.nix
    ./forgejo.nix
    ./garage.nix
    ./tailscale.nix
    ./tor.nix
  ];

  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.secrets = {
    "borg/rsyncnet" = {
      sopsFile = ../../secrets/borg/chunk.yaml;
    };
    "rclone/config" = {
      sopsFile = ../../secrets/rclone.yaml;
    };
    "vaultwarden/env" = {
      sopsFile = ../../secrets/services/vaultwarden.yaml;
    };
    "caddy/env" = {
      sopsFile = ../../secrets/services/caddy.yaml;
    };
    "hedgedoc/env" = {
      sopsFile = ../../secrets/services/hedgedoc.yaml;
    };
    "miniflux/env" = {
      sopsFile = ../../secrets/services/miniflux.yaml;
    };
    "rsyncnet/id_ed25519" = {
      sopsFile = ../../secrets/zh5061/chunk.yaml;
    };
    "attic/env" = {
      sopsFile = ../../secrets/services/attic.yaml;
    };
    "garage/env" = {
      sopsFile = ../../secrets/services/garage.yaml;
    };
    "tailscale/auth" = {
      sopsFile = ../../secrets/services/tailscale.yaml;
    };
    "zipline/env" = {
      sopsFile = ../../secrets/services/zipline.yaml;
    };
  };

  boot = {
    loader.grub.enable = true;
    loader.grub.device = "/dev/vda";
    kernelPackages = pkgs.linuxPackages_latest;
  };

  system.stateVersion = "24.05";

  # network stuff

  networking.hostName = "chunk";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
      53
      853
    ];
    allowedUDPPorts = [
      443
      53
      853
    ];
    extraCommands =
      let
        ethtool = lib.getExe pkgs.ethtool;
        tc = lib.getExe' pkgs.iproute2 "tc";
      in
      ''
        # disable TCP segmentation offload (https://wiki.archlinux.org/title/Advanced_traffic_control#Prerequisites)
        ${ethtool} -K ens18 tso off

        # clear existing rules
        ${tc} qdisc del dev ens18 root || true

        # create HTB hierarchy
        ${tc} qdisc add dev ens18 root handle 1: htb default 30
        ${tc} class add dev ens18 parent 1: classid 1:1 htb rate 100% ceil 100%
        # tailscale
        ${tc} class add dev ens18 parent 1:1 classid 1:10 htb rate 30% ceil 100%
        # caddy
        ${tc} class add dev ens18 parent 1:1 classid 1:20 htb rate 30% ceil 100%
        # rest
        ${tc} class add dev ens18 parent 1:1 classid 1:30 htb rate 40% ceil 100%

        # mark traffic
        iptables -t mangle -A OUTPUT -m cgroup --path "system.slice/tailscaled.service" -j MARK --set-mark 1
        iptables -t mangle -A OUTPUT -m cgroup --path "system.slice/caddy.service" -j MARK --set-mark 2

        # route marked packets
        ${tc} filter add dev ens18 parent 1: protocol ip prio 1 handle 1 fw flowid 1:10
        ${tc} filter add dev ens18 parent 1: protocol ip prio 1 handle 2 fw flowid 1:20
      '';
  };
  networking.interfaces.ens18 = {
    ipv6.addresses = [
      {
        address = "2a0f:85c1:840:2bfb::1";
        prefixLength = 64;
      }
    ];
    ipv4.addresses = [
      {
        address = "31.59.129.225";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway6 = {
    address = "2a0f:85c1:840::1";
    interface = "ens18";
  };
  networking.defaultGateway = {
    address = "31.59.129.1";
    interface = "ens18";
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  users.users.yt = {
    extraGroups = [
      "wheel"
      "networkmanager"
      "podman"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge yt@ytlinux"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyn2+OoRN4nExti+vFQ1NHEZip0slAoCH9C5/FzvgZD yt@ytnix"
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge yt@ytlinux"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyn2+OoRN4nExti+vFQ1NHEZip0slAoCH9C5/FzvgZD yt@ytnix"
  ];
  # for forgejo
  users.users.git = {
    isNormalUser = true;
    home = "/var/lib/forgejo";
    group = "git";
  };
  users.groups.git = { };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    tree
    tmux
    file
    sops
    attic-server
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  programs.gnupg.agent.enable = true;
  programs.git.enable = true;

  my.caddy.enable = true;
  services.caddy.virtualHosts."cy7.sh" = {
    serverAliases = [ "www.cy7.sh" ];
    extraConfig = ''
      import common
      redir https://cything.io temporary
    '';
  };

  # container stuff
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    # create 'docker' alias for podman, to use as
    # drop-in replacement
    dockerCompat = true;
    defaultNetwork.settings = {
      dns_enabled = true;
      ipv6_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";
  environment.enableAllTerminfo = true;

  my.roundcube.enable = true;
  my.zipline.enable = true;
}
