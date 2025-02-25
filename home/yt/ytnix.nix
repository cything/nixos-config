{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./common.nix
    ../foot.nix
    ../niri
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

  home.packages = with pkgs; [
    firefox
    ungoogled-chromium
    librewolf
    bitwarden-desktop
    fastfetch
    nwg-look
    kdePackages.gwenview
    kdePackages.okular
    kdePackages.qtwayland
    mpv
    yt-dlp
    signal-desktop
    pavucontrol
    btop
    jq
    bash-language-server
    sqlite
    usbutils
    clang-tools
    calibre
    tor-browser
    wtype
    bat
    yarn
    rclone
    go
    rustup
    pwgen
    lua-language-server
    gnumake
    minisign
    unzip
    lm_sensors
    sshfs
    gopls
    anki-bin
    trezorctl
    trezor-agent
    q
    opentofu
    terraform-ls
    gdb
    clang
    seahorse
    github-cli
    fuzzel
    nixpkgs-review
    just
    hugo
    ghidra
    sequoia
    sccache
    awscli2
    lldb
    (cutter.withPlugins (
      p: with p; [
        rz-ghidra
        jsdec
        sigdb
      ]
    ))
    ida-free
    patchelf
    radare2
    p7zip
    qbittorrent
    nil
    pkg-config
    gtk2
    gtk2-x11
    android-tools
    frida-tools
    mitmproxy
    openssl
    (python313.withPackages (
      p: with p; [
        python-lsp-server
        pip
        virtualenv
      ]
    ))
    telegram-desktop
    jadx
    gradle
    localsend
    scrcpy
    syncthing
    syncthingtray
    obsidian
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
      signingKey = "~/.ssh/id.key";
    };
    gpg.format = "ssh";
    commit.gpgsign = true;
    core.sshCommand = "ssh -i ~/.ssh/id.key";
  };

  home.sessionVariables = {
    # to make ghidra work on xwayland
    _JAVA_AWT_WM_NONREPARENTING = 1;

    # sccache stuff
    RUSTC_WRAPPER = "${lib.getExe pkgs.sccache}";
    SCCACHE_BUCKET = "sccache";
    SCCACHE_REGION = "us-east-1";
    SCCACHE_ENDPOINT = "https://sccache.s3.cy7.sh";
    SCCACHE_ALLOW_CORE_DUMPS = "true";
    SCCACHE_S3_USE_SSL = "true";
    SCCACHE_CACHE_MULTIARCH = "true";
    SCCACHE_LOG = "warn";
    AWS_DEFAULT_REGION = "us-east-1";
    AWS_ENDPOINT_URL = "https://s3.cy7.sh";
    AWS_ACCESS_KEY_ID = "$(cat /run/secrets/aws/key_id)";
    AWS_SECRET_ACCESS_KEY = "$(cat /run/secrets/aws/key_secret)";
  };
}
