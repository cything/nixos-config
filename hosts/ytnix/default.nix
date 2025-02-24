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
    "services/ntfy" = {
      sopsFile = ../../secrets/services/ntfy.yaml;
    };
    "rsyncnet/id_ed25519" = {
      sopsFile = ../../secrets/zh5061/yt.yaml;
    };
    "newsboat/miniflux" = {
      sopsFile = ../../secrets/newsboat.yaml;
      owner = "yt";
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
  };

  boot = {
    loader = {
      # lanzaboote replaces systemd-boot
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = false; # toggle when installing
    };
    tmp.cleanOnBoot = true;
    # upgrade after https://github.com/tomaspinho/rtl8821ce/issues/356 is fixed
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
        8080  # mitmproxy
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

  environment.systemPackages = with pkgs; [
    tmux
    vim
    wget
    neovim
    git
    python3
    wl-clipboard
    # mako # sway config uses this
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
    sbctl # secure boot
    wine-wayland
    wine64
    solaar
    gtk3
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

  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
    ibm-plex
  ];
  fonts.enableDefaultPackages = true;

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
      target_preserve = "*d";
      target_preserve_min = "no";
      target = "/mnt/external/btr_backup/ytnix";
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
  programs.nix-ld.dev = {
    enable = true;
    # nix run github:thiagokokada/nix-alien#nix-alien-find-libs ./<binary>
    libraries = with pkgs; [
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

  programs.ssh = {
    askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
    startAgent = true;
    enableAskPassword = true;
  };

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

  programs.java = {
    enable = true;
    binfmt = true;
  };
}
