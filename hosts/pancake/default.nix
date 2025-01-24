{
  modulesPath,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../common.nix
    # ./hardware-configuration.nix
    ../zsh.nix
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdhAQYy0+vS+QmyCd0MAbqbgzyMGcsuuFyf6kg2yKge yt@ytlinux"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyn2+OoRN4nExti+vFQ1NHEZip0slAoCH9C5/FzvgZD yt@ytnix"
  ];

  system.stateVersion = "24.11";

  environment.systemPackages = with pkgs; [
    curl
    git
  ];

  # network stuff
  networking.hostName = "pancake";
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

  networking.wireless.enable = true;
  networking.wireless.networks = {
    "36 Halsey" = {
      psk = "Canada2022";
    };
    "cy" = {
      psk = "12345678";
    };
  };

  hardware.enableRedistributableFirmware = true;

  users.users.yt.extraGroups = [
    "wheel"
  ];
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
  users.users.root.initialHashedPassword = "";
  users.users.yt.initialHashedPassword = "";

  # remove this after https://github.com/NixOS/nixpkgs/pull/375165 lands on unstable
  boot.kernelPackages = lib.mkForce inputs.nixpkgs-rpi.legacyPackages.aarch64-linux.linuxKernel.packages.linux_rpi3;
}
