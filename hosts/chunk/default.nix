{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ./gitlab.nix
    ./borg.nix
    ./rclone.nix
    ./postgres.nix
    ./wireguard.nix
    ./adguard.nix
    ./hedgedoc.nix
    ./miniflux.nix
    ./ntfy.nix
    ./redlib.nix
    ./vaultwarden.nix
    ./wireguard.nix
    ./grafana.nix
    ./tor.nix
  ];

  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.secrets = {
    "borg/rsyncnet" = {
      sopsFile = ../../secrets/borg/chunk.yaml;
    };
    "services/ntfy" = {
      sopsFile = ../../secrets/services/ntfy.yaml;
    };
    "rclone/env" = {
      sopsFile = ../../secrets/rclone/chunk.yaml;
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
    "wireguard/private" = {
      sopsFile = ../../secrets/wireguard/chunk.yaml;
    };
    "wireguard/psk-yt" = {
      sopsFile = ../../secrets/wireguard/chunk.yaml;
    };
    "wireguard/psk-phone" = {
      sopsFile = ../../secrets/wireguard/chunk.yaml;
    };
    "miniflux/env" = {
      sopsFile = ../../secrets/services/miniflux.yaml;
    };
    "gitlab/root" = {
      sopsFile = ../../secrets/services/gitlab.yaml;
      owner = config.users.users.git.name;
    };
    "gitlab/secret" = {
      sopsFile = ../../secrets/services/gitlab.yaml;
      owner = config.users.users.git.name;
    };
    "gitlab/jws" = {
      sopsFile = ../../secrets/services/gitlab.yaml;
      owner = config.users.users.git.name;
    };
    "gitlab/db" = {
      sopsFile = ../../secrets/services/gitlab.yaml;
      owner = config.users.users.git.name;
    };
    "gitlab/otp" = {
      sopsFile = ../../secrets/services/gitlab.yaml;
      owner = config.users.users.git.name;
    };
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  system.stateVersion = "24.05";

  # network stuff

  networking.hostName = "chunk";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443 53 853];
    allowedUDPPorts = [443 51820 53 853]; # 51820 is wireguard
    trustedInterfaces = ["wg0" "br-2a019a56bbcc"]; # the second one is docker, idk if this changes
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
  networking.nameservers = ["127.0.0.1" "::1"];

  time.timeZone = "America/Toronto";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  users.users.yt = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker"];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge yt@ytlinux"];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge yt@ytlinux"];

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    tree
    python3Full
    tmux
    borgbackup
    rclone
    file
    sops
    age
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

  services.caddy = {
    enable = true;
    configFile = ./Caddyfile;
    environmentFile = config.sops.secrets."caddy/env".path;
    logFormat = lib.mkForce "level INFO";
  };

  virtualisation.docker.enable = true;
}
