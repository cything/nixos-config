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

  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.secrets = {
    "restic/zh5061".sopsFile = ../../secrets/restic/yt.yaml;
    "rsyncnet/id_ed25519".sopsFile = ../../secrets/zh5061/id_ed25519.yaml;
    "tailscale/auth".sopsFile = ../../secrets/services/tailscale.yaml;
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.limine = {
    enable = true;
    maxGenerations = 50;
    enableEditor = true; # FDE anyway
  };

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

    firewall = {
      enable = true;
      extraInputRules = ''
        # calibre
        ip saddr 192.168.1.0/24 tcp dport 9090 accept
        ip saddr 192.168.122.0/24 accept
      '';
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
    borgbackup
    killall
    sops
    lsof
    file
    efibootmgr
    pavucontrol
    jmtpfs
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

  my.backup = {
    enable = true;
    exclude = [
      "/home/**/Downloads"
    ];
    repo = "yt";
    passFile = config.sops.secrets."restic/zh5061".path;
    sshKeyFile = config.sops.secrets."rsyncnet/id_ed25519".path;
  };

  # fix mic led indicator
  systemd.services.turn-off-mic-led =
    let
      device = "sys-devices-pci0000:00-0000:00:08.1-0000:07:00.1-sound-card0-controlC0.device";
    in
    {
      wantedBy = [ device ];
      requiredBy = [ device ];
      serviceConfig.Type = "oneshot";
      script = ''
        echo off > /sys/class/sound/ctl-led/mic/mode
      '';
    };

  # fix dolphin not miming
  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/auth".path;
    openFirewall = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      # "--exit-node=chunk"
      "--accept-dns=false"
      "--operator=yt"
      "--exit-node-allow-lan-access"
    ];
    extraDaemonFlags = [
      "--no-logs-no-support"
    ];
  };

  my.containerization.enable = true;
}
