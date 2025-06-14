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
    # ../codium.nix
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
      bitwarden-desktop
      fastfetch
      (with kdePackages; [
        gwenview
        okular
      ])
      mpv
      signal-desktop
      btop
      jq
      usbutils
      calibre
      tor-browser
      wtype
      bat
      rclone
      (rust-bin.selectLatestNightlyWith (
        toolchain:
        toolchain.default.override {
          extensions = [ "rust-src" ];
          targets = [ "aarch64-unknown-linux-musl" ];
        }
      ))
      gnumake
      unzip
      anki-bin
      gdb
      fuzzel
      hugo
      sccache
      awscli2
      p7zip
      qbittorrent
      android-tools
      (python313.withPackages (
        p: with p; [
          python-lsp-server
          pip
          virtualenv
        ]
      ))
      scrcpy
      syncthing
      (with llvmPackages; [
        clangUseLLVM
        compiler-rt
        libllvm
      ])
      nix-output-monitor
      cinny-desktop
      minio-client
      keepassxc
      jujutsu
      ffmpeg
      typst
      pavucontrol
      (ungoogled-chromium.override {
        enableWideVine = true;
      })

      # reversing
      radare2
      jadx
      frida-tools
      mitmproxy
      (cutter.withPlugins (
        p: with p; [
          rz-ghidra
          jsdec
          sigdb
        ]
      ))
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

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      lua-language-server
      nixd
      rust-analyzer
      fzf
      fd
      ripgrep
      bat
      delta
      taplo
      llvmPackages.clang-tools
      pyright
      tree-sitter
      nodejs
      nixfmt-rfc-style
    ];
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

  programs.firefox.enable = true;

  gtk = {
    enable = true;
    theme.package = pkgs.gnome-themes-extra;
    theme.name = "Adwaita-dark";
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-qt;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
