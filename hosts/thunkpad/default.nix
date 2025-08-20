{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
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
    steam-run-free # steam-run without steam
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

  services.logind = {
    lidSwitch = "suspend";
    powerKey = "hibernate";
  };

  # fix for wifi not work after resume from hibernation
  # see https://wiki.archlinux.org/title/Lenovo_ThinkPad_T14s_(AMD)_Gen_3#Network_/_Wi-Fi
  systemd.services.ath11k-suspend = {
    enable = true;
    before = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' pkgs.kmod "rmmod"} ath11k_pci";
    };
  };

  systemd.services.ath11k-resume = {
    enable = true;
    after = [
      "suspend.target"
      "suspend-then-hibernate.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
    wantedBy = [
      "suspend.target"
      "suspend-then-hibernate.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' pkgs.kmod "modprobe"} ath11k_pci";
    };
  };

  my.libvirt.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  programs.fuse.userAllowOther = true;
}
