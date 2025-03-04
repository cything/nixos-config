{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../common.nix
    ../zsh.nix
    ./tailscale.nix
  ];

  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.secrets = {
    "borg/rsyncnet" = {
      sopsFile = ../../secrets/borg/yt.yaml;
    };
    "rsyncnet/id_ed25519" = {
      sopsFile = ../../secrets/zh5061/yt.yaml;
    };
    "tailscale/auth" = {
      sopsFile = ../../secrets/services/tailscale.yaml;
    };
    "aws/key_id" = {
      sopsFile = ../../secrets/yt/aws.yaml;
      owner = "yt";
    };
    "aws/key_secret" = {
      sopsFile = ../../secrets/yt/aws.yaml;
      owner = "yt";
    };
    "vaultwarden/env" = {
      sopsFile = ../../secrets/services/vaultwarden.yaml;
    };
  };

  boot = {
    loader = {
      # lanzaboote replaces systemd-boot
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    extraModulePackages = with config.boot.kernelPackages; [
      rtl8821ce
    ];
    kernelParams = [
      # see https://github.com/tomaspinho/rtl8821ce#pcie-active-state-power-management
      "pcie_aspm=off"
    ];
    # see https://github.com/tomaspinho/rtl8821ce#wi-fi-not-working-for-kernel--59
    extraModprobeConfig = ''
      blacklist rtw88_8821ce
    '';
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    kernel.sysctl."kernel.sysrq" = 1;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
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
        powersave = false;
      };
    };
    resolvconf.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        8080 # mitmproxy
        22000 # syncthing
      ];
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
      # https://julian.pages.freedesktop.org/wireplumber/daemon/configuration/bluetooth.html#bluetooth-configuration
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [
          "a2dp_sink"
          "a2dp_source"
          "hsp_hs"
          "hsp_ag"
          "hfp_hf"
          "hfp_ag"
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
    "disk"
    "adbusers"
  ];

  environment.systemPackages = with pkgs; lib.flatten [
    tmux
    vim
    wget
    tree
    kitty
    borgbackup
    htop
    file
    dnsutils
    q
    age
    compsize
    wireguard-tools
    traceroute
    sops
    sbctl # secure boot
    lm_sensors
    sshfs
    openssl
    just
    killall
    lshw
    bubblewrap
    fuse-overlayfs
    dwarfs
    wineWowPackages.stagingFull
    (with gst_all_1; [
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-plugins-base
    ])
    vulkan-loader
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
        pkgs.gamemode
      ];
    })
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  system.stateVersion = "24.05";

  programs.gnupg.agent.enable = true;

  services.displayManager = {
    enable = true;
    autoLogin.user = "yt";
    defaultSession = "plasma";
    sddm = {
      enable = true;
      wayland.enable = true;
      autoNumlock = true;
    };
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.roboto-mono
      ibm-plex
    ];
    enableDefaultPackages = true;
  };

  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

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
      "/home/yt/Videos"
    ];
    repo = "yt";
    passFile = config.sops.secrets."borg/rsyncnet".path;
    sshKeyFile = config.sops.secrets."rsyncnet/id_ed25519".path;
  };

  services.btrbk.instances.local = {
    onCalendar = "hourly";
    # only create snapshots automatically. backups are triggered manually with `btrbk resume`
    snapshotOnly = true;
    settings = {
      snapshot_preserve_min = "latest";
      target_preserve = "30d";
      target_preserve_min = "2d";
      target = "/mnt/target/btr_backup/ytnix";
      stream_compress = "zstd";
      stream_compress_level = "8";
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
  programs.gamescope.enable = true;

  services.logind = {
    lidSwitch = "suspend";
    powerKey = "poweroff";
    suspendKey = "hibernate";
  };

  xdg.mime.defaultApplications = {
    "application/pdf" = "okular.desktop";
    "image/*" = "gwenview.desktop";
    "*/html" = "chromium-browser.desktop";
  };

  virtualisation = {
    libvirtd.enable = true;
  };
  programs.virt-manager.enable = true;
  my.containerization.enable = true;

  services.usbmuxd.enable = true;
  programs.nix-ld.dev = {
    enable = true;
    # nix run github:thiagokokada/nix-alien#nix-alien-find-libs ./<binary>
    libraries = with pkgs; [
      # TODO: revisit what we actually need
      mesa
      extest
      stdenv.cc.cc
      libGL
      fontconfig
      libxkbcommon
      zlib
      libxml2
      dbus
      freetype
      egl-wayland
      waylandpp
      cairo
      xcb-util-cursor
      libplist
      p11-kit
      kdePackages.qtwayland
      qt6.full
      qt6.qtwayland
      qt5.full
      qt5.qtwayland
      xorg.libX11
      xorg.libxcb
      xorg.xcbutilwm
      xorg.xcbutilimage
      xorg.xcbutilkeysyms
      xorg.xcbutilrenderutil
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.libxkbfile
      xorg.libxshmfence
      xorg.libXxf86vm
      xorg.libSM
      gtk3
      pango
      gdk-pixbuf
      glib
      libnotify
      SDL2
      libpng
      libjpeg8
      libtiff
      curl
      pcre2
      gsettings-desktop-schemas
    ];
  };
  programs.evolution.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
    ];
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-media-sdk
    ];
  };

  services.ollama.enable = false;

  services.trezord.enable = false;

  programs.niri.enable = false;
  programs.niri.package = pkgs.niri-unstable;
  programs.xwayland.enable = true;

  services.udev.extraHwdb = ''
    SUBSYSTEM=="usb", SYSFS{idVendor}=="090c", SYSFS{idProduct}=="1000", ACTION=="add", GROUP="users", MODE="0664"
  '';

  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = true;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.adb.enable = true;
  services.envfs.enable = true;
  programs.kdeconnect.enable = true;
  programs.dconf.enable = true;

  programs.ccache.enable = true;
  nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];

  services.postgresql = {
    enable = true;
    settings.port = 5432;
    package = pkgs.postgresql_17;
    enableTCPIP = true;
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    environmentFile = config.sops.secrets."vaultwarden/env".path;
    config = {
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = "8081";
      DATABASE_URL = "postgresql://vaultwarden:vaultwarden@127.0.0.1:5432/vaultwarden";
    };
  };
}
