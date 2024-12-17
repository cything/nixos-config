{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common.nix
  ];

  sops.secrets = {
    "services/borg/yt" = {
      sopsFile = ../../secrets/services/borg/yt.yaml;
    };
    "services/ntfy" = {
      sopsFile = ../../secrets/services/ntfy.yaml;
    };
    "wireguard/yt/private" = {
      sopsFile = ../../secrets/wireguard/yt.yaml;
    };
    "wireguard/yt/psk" = {
      sopsFile = ../../secrets/wireguard/yt.yaml;
    };
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
    nameservers = ["31.59.129.225" "2a0f:85c1:840:2bfb::1"];
    resolvconf.enable = true;
    firewall = {
      allowedUDPPorts = [51820]; # for wireguard
      trustedInterfaces = ["wg0"];
    };
  };
  programs.nm-applet.enable = true;

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
        "bluez5.roles" = ["a2dp_sink" "a2dp_source"];
      };
    };
    # https://wiki.archlinux.org/title/Bluetooth_headset#Connecting_works,_sound_plays_fine_until_headphones_become_idle,_then_stutters
    wireplumber.extraConfig.disableSuspend = {
      "monitor.bluez.rules" = {
        matches = [
          {
            "node.name" = "bluez_output.*";
          }
        ];
      };
      actions = {
        update-props = {
          "session.suspend-timeout-seconds" = 0;
        };
      };
    };
  };

  services.libinput.enable = true;

  users.users.yt = {
    isNormalUser = true;
    extraGroups = ["wheel" "libvirtd" "docker"];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

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
    wireguard-tools
    traceroute
    sops
    restic
    haskell-language-server
    ghc
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
  # security.sudo.wheelNeedsPassword = false;

  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
  ];

  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  programs.sway.enable = true;

  services.borgbackup.jobs.ytnixRsync = {
    paths = ["/root" "/home" "/var/lib" "/var/log" "/opt" "/etc"];
    exclude = [
      "**/.cache"
      "**/node_modules"
      "**/cache"
      "**/Cache"
      "/var/lib/docker"
      "/var/lib/private/ollama"
      "/home/**/Downloads"
      "**/.steam"
      "**/.rustup"
      "**/.docker"
      "**/borg"
    ];
    repo = "de3911@de3911.rsync.net:borg/yt";
    encryption = {
      mode = "repokey-blake2";
      passCommand = ''cat ${config.sops.secrets."borg/yt/rsyncnet".path}"'';
    };
    environment = {
      BORG_RSH = "ssh -i /home/yt/.ssh/id_ed25519";
      BORG_REMOTE_PATH = "borg1";
    };
    compression = "auto,zstd";
    startAt = "daily";
    extraCreateArgs = ["--stats"];
    # warnings are often not that serious
    failOnWarnings = false;
    postHook = ''
      ${pkgs.curl}/bin/curl -u $(cat ${config.sops.secrets."services/ntfy/ntfy".path}) -d "ytnixRsync: backup completed with exit code: $exitStatus
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
  services.tumbler.enable = true;

  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
  };
  programs.virt-manager.enable = true;

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

  services.ollama.enable = true;

  # wireguard setup
  networking.wg-quick.interfaces.wg0 = {
    address = ["10.0.0.2/24" "fdc9:281f:04d7:9ee9::2/64"];
    privateKeyFile = config.sops.secrets."wireguard/yt/private".path;
    peers = [
      {
        publicKey = "a16/F/wP7HQIUtFywebqPSXQAktPsLgsMLH9ZfevMy0=";
        allowedIPs = ["0.0.0.0/0" "::/0"];
        endpoint = "31.59.129.225:51820";
        persistentKeepalive = 25;
        presharedKeyFile = config.sops.secrets."wireguard/yt/psk".path;
      }
    ];
  };
}
