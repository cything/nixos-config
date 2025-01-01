{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ../zsh.nix
    {
      disabledModules = [
        "services/backup/btrbk.nix"
      ];
    }
    (inputs.nixpkgs-btrbk + "/nixos/modules/services/backup/btrbk.nix")
  ];

  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.secrets = {
    "borg/rsyncnet" = {
      sopsFile = ../../secrets/borg/yt.yaml;
    };
    "services/ntfy" = {
      sopsFile = ../../secrets/services/ntfy.yaml;
    };
    "wireguard/private" = {
      sopsFile = ../../secrets/wireguard/yt.yaml;
    };
    "wireguard/psk" = {
      sopsFile = ../../secrets/wireguard/yt.yaml;
    };
    "rsyncnet/id_ed25519" = {
      sopsFile = ../../secrets/de3911/yt.yaml;
    };
    "newsboat/miniflux" = {
      sopsFile = ../../secrets/newsboat.yaml;
      owner = "yt";
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxPackages_latest;

    # fix bluetooth
    extraModulePackages = with config.boot.kernelPackages; [
      rtw88
    ];
    # see https://bugzilla.kernel.org/show_bug.cgi?id=215496#c22
    # and https://github.com/lwfinger/rtw88/issues/61
    extraModprobeConfig = ''
      options rtw88_core disable_lps_deep=y
      options rtw88_pci disable_aspm=y
    '';
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
      wifi = {
        backend = "iwd";
        powersave = false; # fixes bluetooth; see above
      };
    };
    nameservers = [
      "31.59.129.225"
      "2a0f:85c1:840:2bfb::1"
    ];
    resolvconf.enable = true;
    firewall = {
      allowedUDPPorts = [ 51820 ]; # for wireguard
      trustedInterfaces = [ "wg0" ];
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
        "bluez5.roles" = [
          "a2dp_sink"
          "a2dp_source"
        ];
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

  users.users.yt.extraGroups = [
    "wheel"
    "libvirtd"
    "docker"
  ];

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
    ibm-plex
  ];

  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  programs.sway.enable = true;

  my.backup = {
    enable = true;
    jobName = "ytnixRsync";
    exclude = [
      "/var/lib/private/ollama"
      "/home/**/Downloads"
      "/home/yt/fun"
      "/home/yt/.local/share/Steam"
      "**/.wine"
      "/home/yt/Games"
    ];
    repo = "yt";
    passFile = config.sops.secrets."borg/rsyncnet".path;
    sshKeyFile = config.sops.secrets."rsyncnet/id_ed25519".path;
  };

  services.btrbk.instances.local = {
    onCalendar = "hourly";
    snapshotOnly = true;
    settings = {
      # only create snapshots automatically. backups are triggered manually with `btrbk resume`
      snapshot_preserve = "7d";
      snapshot_preserve_min = "2d";
      target_preserve = "*d";
      target_preserve_min = "no";
      target = "/mnt/external/btr_backup/ytnix";
      stream_compress = "zstd";
      snapshot_dir = "/snapshots";
      subvolume = {
        "/home" = { };
        "/" = { };
      };
    };
  };

  programs.steam = {
    enable = true;
    extest.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };
  hardware.steam-hardware.enable = true;

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
    autostart = false;
    address = [
      "10.0.0.2/24"
      "fdc9:281f:04d7:9ee9::2/64"
    ];
    privateKeyFile = config.sops.secrets."wireguard/private".path;
    peers = [
      {
        publicKey = "a16/F/wP7HQIUtFywebqPSXQAktPsLgsMLH9ZfevMy0=";
        allowedIPs = [
          "0.0.0.0/0"
          "::/0"
        ];
        endpoint = "31.59.129.225:51820";
        persistentKeepalive = 25;
        presharedKeyFile = config.sops.secrets."wireguard/psk".path;
      }
    ];
  };

  services.trezord.enable = true;
}
