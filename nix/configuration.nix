{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ytnix";
  networking.networkmanager.enable = true;
  # disable 2.4 GHz cause i have a shitty wireless card
  # that interferes with bluetooth otherwise
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Rank = {
        BandModifier2_4GHz = 0.0;
      };
    };
  };
  networking.networkmanager.wifi.backend = "iwd";
  time.timeZone = "America/Toronto";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;

  users.users.yt = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      firefox
      ungoogled-chromium
      librewolf
      bitwarden-desktop
      bitwarden-cli
      aerc
      delta
      fzf
      zoxide
      eza
      fastfetch
    ];
  };

  environment.systemPackages = with pkgs; [
    tmux
    vim
    wget
    neovim
	  git
	  python3
	  grim
	  slurp
	  wl-clipboard
	  mako
    tree
    kitty
    rofi-wayland
    rofimoji
    cliphist
    borgbackup
    jq
    brightnessctl
    alsa-utils
    nixd
    veracrypt
    kdePackages.dolphin
    bluetuith
    libimobiledevice
    networkmanagerapplet
  ];

  system.stateVersion = "24.05";

  services.gnome.gnome-keyring.enable = true;
  programs.gnupg.agent.enable = true;

  # programs.sway = {
  #   enable = true;
  #   wrapperFeatures.gtk = true;
  # };
  services.displayManager.defaultSession = "hyprland";
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  programs.waybar.enable = true;
  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  fonts.packages = with pkgs; [
    nerdfonts
  ];
  nixpkgs.config.allowUnfree = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.hyprland = {
    enable = true;
    # withUWSM = true;
  };
}

