{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./common.nix
    ../irssi.nix
    ../kitty.nix
    ../codium.nix
  ];
  home = {
    username = "yt";
    homeDirectory = "/home/yt";
    stateVersion = "24.05";
  };
  programs.home-manager.enable = true;

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 23;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages =
    with pkgs;
    lib.flatten [
      ungoogled-chromium
      librewolf
      bitwarden-desktop
      bitwarden-cli
      fastfetch
      (with kdePackages; [
        gwenview
        okular
      ])
      mpv
      signal-desktop
      btop
      jq
      sqlite
      usbutils
      calibre
      tor-browser
      wtype
      bat
      rclone
      go
      (rust-bin.selectLatestNightlyWith (
        toolchain:
        toolchain.default.override {
          extensions = [ "rust-src" ];
        }
      ))
      pwgen
      gnumake
      unzip
      anki-bin
      trezorctl
      q
      gdb
      fuzzel
      hugo
      ghidra
      sccache
      awscli2
      (cutter.withPlugins (
        p: with p; [
          rz-ghidra
          jsdec
          sigdb
        ]
      ))
      p7zip
      qbittorrent
      nil
      android-tools
      frida-tools
      mitmproxy
      (python313.withPackages (
        p: with p; [
          python-lsp-server
          pip
          virtualenv
        ]
      ))
      jadx
      scrcpy
      syncthing
      syncthingtray
      (with llvmPackages; [
        clangUseLLVM
        compiler-rt
        libllvm
      ])
      nix-output-monitor
      wl-clipboard-rs
      pixelflasher
      cinny-desktop
      freetube
      gopls
      rust-analyzer
    ];

  home.sessionVariables = {
    # to make ghidra work on xwayland
    _JAVA_AWT_WM_NONREPARENTING = 1;

    # sccache stuff
    RUSTC_WRAPPER = "${lib.getExe pkgs.sccache}";
    SCCACHE_BUCKET = "sccache";
    SCCACHE_REGION = "us-east-1";
    SCCACHE_ENDPOINT = "https://s3.cy7.sh";
    SCCACHE_ALLOW_CORE_DUMPS = "true";
    SCCACHE_S3_USE_SSL = "true";
    SCCACHE_CACHE_MULTIARCH = "true";
    SCCACHE_LOG = "warn";
    AWS_DEFAULT_REGION = "us-east-1";
    AWS_ENDPOINT_URL = "https://s3.cy7.sh";
    AWS_ACCESS_KEY_ID = "$(cat /run/secrets/aws/key_id)";
    AWS_SECRET_ACCESS_KEY = "$(cat /run/secrets/aws/key_secret)";

    # bitwarden ssh agent
    SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
  ];

  programs.feh.enable = true;

  xdg.configFile = {
    mpv.source = ../mpv;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git.extraConfig = {
    user = {
      signingKey = "~/.ssh/id_ed25519";
    };
    gpg.format = "ssh";
    commit.gpgsign = true;
  };

  programs.nix-index-database.comma.enable = true;
  programs.helix = {
    enable = true;
    settings = {
      theme = "github_dark";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
      };
      keys.insert = {
        "C-[" = "normal_mode";
      };
    };
  };
}
