{
  modulesPath,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../common.nix
    ./disk-config.nix
    ./hardware-configuration.nix
    ./ghost.nix
    ./ntfy.nix
  ];

  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.secrets = {
    "caddy/env" = {
      sopsFile = ../../secrets/services/caddy.yaml;
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge yt@ytlinux"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyn2+OoRN4nExti+vFQ1NHEZip0slAoCH9C5/FzvgZD yt@ytnix"
  ];

  system.stateVersion = "24.05";

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.yt = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge yt@ytlinux"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyn2+OoRN4nExti+vFQ1NHEZip0slAoCH9C5/FzvgZD yt@ytnix"
    ];
  };
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # network stuff
  networking.hostName = "titan";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
    allowedUDPPorts = [
      443
    ];
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

  services.caddy = {
    enable = true;
    configFile = ./Caddyfile;
    environmentFile = config.sops.secrets."caddy/env".path;
    logFormat = lib.mkForce "level INFO";
  };
}
