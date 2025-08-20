{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../common.nix
      ../zsh.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "25.05";

  networking = {
    hostName = "thunkpad";
    wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      dns = "none";
      wifi = {
        backend = "iwd";
        powersave = false;
      };
    };
  };

  time.timeZone = "America/Chicago";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    kitty
    foot
    restic
  ];

  fonts = {
    packages =
      (with pkgs; [
        ibm-plex
      ])
      ++ (with pkgs.nerd-fonts; [
        roboto-mono
        jetbrains-mono
      ]);
    enableDefaultPackages = true;
  };

  users.users.yt = {
    isNormalUser = true;
    description = "yt";
    extraGroups = [ "wheel" ];
    home = "/home/yt";
  };

  programs.ssh.startAgent = true;

  my.sway.enable = true;
}

