{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  disabledModules = ["services/web-servers/caddy/default.nix"];
  imports = [
    ./hardware-configuration.nix
    "${inputs.testpkgs}/nixos/modules/services/web-servers/caddy"
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
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.secrets = {
    "borg/crash" = {};
    "ntfy" = {};
    "rclone" = {};
    "vaultwarden" = {};
    "caddy" = {};
    "hedgedoc" = {};
    "wireguard/private" = {};
    "wireguard/psk" = {};
    "wireguard/pskphone" = {};
    "miniflux" = {};
    "gitlab/root" = {
      owner = config.users.users.git.name;
      group = config.users.users.git.group;
    };
    "gitlab/secret" = {
      owner = config.users.users.git.name;
      group = config.users.users.git.group;
    };
    "gitlab/jws" = {
      owner = config.users.users.git.name;
      group = config.users.users.git.group;
    };
    "gitlab/db" = {
      owner = config.users.users.git.name;
      group = config.users.users.git.group;
    };
    "gitlab/otp" = {
      owner = config.users.users.git.name;
      group = config.users.users.git.group;
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
  };
  networking.defaultGateway6 = {
    address = "2a0f:85c1:840::1";
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
    environmentFile = "/run/secrets/caddy";
    logFormat = lib.mkForce "level INFO";
  };

  virtualisation.docker.enable = true;
}
