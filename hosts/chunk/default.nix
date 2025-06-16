{
  pkgs,
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
    ./immich.nix
    ./forgejo.nix
    ./garage.nix
    ./tailscale.nix
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
    "garage/env" = {
      sopsFile = ../../secrets/services/garage.yaml;
    };
    "tailscale/auth" = {
      sopsFile = ../../secrets/services/tailscale.yaml;
    };
    "karakeep/env" = {
      sopsFile = ../../secrets/services/karakeep.yaml;
    };
  };

  boot = {
    loader.grub.enable = true;
    loader.grub.device = "/dev/vda";
    kernelPackages = pkgs.linuxPackages_latest;
  };

  system.stateVersion = "24.05";

  # network stuff
  networking = {
    hostName = "chunk";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [
        "tailscale0"
        "podman1"
      ];
      allowedTCPPorts = [
        22
        80
        443
      ];
      allowedUDPPorts = [
        443
      ];
    };
    interfaces.ens18 = {
      useDHCP = true;
      ipv6.addresses = [
        {
          address = "2a0f:85c1:840:2bfb::1";
          prefixLength = 64;
        }
      ];
    };
  };

  users.users.yt = {
    extraGroups = [
      "wheel"
      "networkmanager"
      "podman"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfubDWr0kRm2o4DqaK6l1s4NCdTkljXZWKWCiF5nX+6"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIA/IX9OFEhHS9Dl8nrtHkL7j7hhy7in9OAY/hVuzEGL0AAAABHNzaDo="
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge yt@ytlinux"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfubDWr0kRm2o4DqaK6l1s4NCdTkljXZWKWCiF5nX+6"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIA/IX9OFEhHS9Dl8nrtHkL7j7hhy7in9OAY/hVuzEGL0AAAABHNzaDo="
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
    neovim
    wget
    curl
    tree
    tmux
    file
    sops
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

  programs.git.enable = true;

  my.caddy.enable = true;
  my.containerization.enable = true;
  my.authelia.enable = true;
  my.karakeep = {
    enable = false;
    dataDir = "/opt/karakeep";
  };
  my.roundcube.enable = true;
}
