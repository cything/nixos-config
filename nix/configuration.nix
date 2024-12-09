{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.secrets = {
    "borg/yt" = { };
    "azure" = { };
    "ntfy" = { };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [
      rtl8821ce
    ];
  };

  networking = {
    hostName = "ytnix";
    # nftables.enable = true;
    wireless.iwd = {
      enable = true;
      settings = {
        Rank = {
          # disable 2.4 GHz cause i have a shitty wireless card
          # that interferes with bluetooth otherwise
          BandModifier2_4GHz = 0.0;
        };
      };
    };
    networkmanager = {
      enable = true;
      dns = "none";
      wifi.backend = "iwd";
    };
    nameservers = [ "127.0.0.1" "::1" ];
    resolvconf.enable = true;
    firewall = {
      trustedInterfaces = [ "wgnord" ];
    };
  };
  programs.nm-applet.enable = true;
  time.timeZone = "America/Toronto";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.extraConfig.bluetoothEnhancements = {
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [ "a2dp_sink" "a2dp_source" ];
      };
    };
  };

  services.libinput.enable = true;

  users.users.yt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "docker" ];
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
      discord
      nwg-look
      element-desktop-wayland
      kdePackages.gwenview
      kdePackages.okular
      kdePackages.qtwayland
      mpv
      yt-dlp
      signal-desktop
      cosign
      azure-cli
      pavucontrol
      btop
      stockfish
      cutechess
	    grim
	    slurp
      rofi-wayland
      rofimoji
      cliphist
      jq
      bash-language-server
      duckdb
      sqlite
      usbutils
      llvmPackages_19.clang-tools
      ghc
      zola
      calibre
      tor-browser
      wtype
      bat
      yarn
      rclone
      go
      rustc
      cargo
      clang_19
      rust-analyzer
      clippy
      pwgen
      lua-language-server
      gnumake
      foot
      minisign
      unzip
      obsidian
      lm_sensors
      activitywatch
      aw-watcher-window-wayland
      aw-qt
      aw-watcher-afk
      sshfs
      nextcloud-client
      python312Packages.python-lsp-server

      (callPackage ./anki-bin.nix {})
    ];
  };

  environment.systemPackages = with pkgs; [
    tmux
    vim
    wget
    neovim
	  git
	  python3
	  wl-clipboard
	  mako
    tree
    kitty
    borgbackup
    brightnessctl
    alsa-utils
    nixd
    veracrypt
    bluetuith
    libimobiledevice
    pass-wayland
    htop
    file
    dnsutils
    age
    compsize
    wgnord
    wireguard-tools
    traceroute
    sops
    restic
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ANKI_WAYLAND = "1";
  };

  system.stateVersion = "24.05";

  services.gnome.gnome-keyring.enable = true;
  programs.gnupg.agent.enable = true;

  services.displayManager.defaultSession = "sway";
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  programs.waybar.enable = true;
  programs.zsh.enable = true;
  # security.sudo.wheelNeedsPassword = false;

  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
  ];
  nixpkgs.config = {
    allowUnfree = true;
    chromium = {
      enableWideVine = true;
      commandLineArgs = "--ozone-platform-hint=wayland --enable-features=WebUIDarkMode";
    };
  };

  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.sway.enable = true;

  services.borgbackup.jobs.ytnixRsync = {
    paths = [ "/root" "/home" "/var/lib" "/var/log" "/opt" "/etc" ];
    exclude = [
      "**/.cache"
      "**/node_modules"
      "**/cache"
      "**/Cache"
      "/var/lib/docker"
      "/home/**/Downloads"
      "**/.steam"
      "**/.rustup"
      "**/.docker"
      "**/borg"
    ];
    repo = "de3911@de3911.rsync.net:borg/yt";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /run/secrets/borg/yt";
    };
    environment = {
      BORG_RSH = "ssh -i /home/yt/.ssh/id_ed25519";
      BORG_REMOTE_PATH = "borg1";
    };
    compression = "auto,zstd";
    startAt = "daily";
    extraCreateArgs = [ "--stats" ];
    # warnings are often not that serious
    failOnWarnings = false;
    postHook = ''
        ${pkgs.curl}/bin/curl -u $(cat /run/secrets/ntfy) -d "ytnixRsync: backup completed with exit code: $exitStatus
        $(journalctl -u borgbackup-job-ytnixRsync.service|tail -n 5)" \
        https://ntfy.cything.io/chunk
      '';
  };
  
  services.btrbk.instances.local = {
    onCalendar = "hourly";
    settings = {
      snapshot_preserve = "2w";
      snapshot_preserve_min = "2d";
      snapshot_dir = "/snapshots";
      subvolume = {
        "/home" = {};
        "/" = {};
      };
    };
  };

  programs.steam.enable = true;

  services.logind = {
    lidSwitch = "hibernate";
    suspendKey = "ignore";
    powerKey = "hibernate";
  };

  xdg.mime.defaultApplications = {
    "application/pdf" = "okular.desktop";
    "image/*" = "gwenview.desktop";
    "*/html" = "chromium-browser.desktop";
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  # preference changes don't work in thunar without this
  programs.xfconf.enable = true;
  # mount, trash and stuff in thunar
  services.gvfs.enable = true;
  # thumbnails in thunar
  services.tumbler.enable =true;

  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
  };
  programs.virt-manager.enable = true;

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
    };
  };

  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  nix.gc = {
    automatic = true;
    dates = "19:00";
    persistent = true;
    options = "--delete-older-than 60d";
  };

  services.usbmuxd.enable = true;
  programs.nix-ld.enable = true;
  programs.evolution.enable = true;

  # this is true by default and mutually exclusive with
  # programs.nix-index
  programs.command-not-found.enable = false;
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];
  };

  nix.settings.auto-optimise-store = true;

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-media-sdk
    ];
  };
}
