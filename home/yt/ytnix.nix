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
    ../vscode.nix
    ../plasma.nix
  ];
  home = {
    username = "yt";
    homeDirectory = "/home/yt";
    stateVersion = "24.05";
  };
  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  # keep this commented when using plasma
  # otherwise "system settings" in KDE will not function
  # qt = {
  #   enable = true;
  #   platformTheme.name = "kde";
  #   style.name = "breeze-dark";
  #   style.package = pkgs.kdePackages.breeze;
  # };

  # this one too
  # gtk = {
  #   enable = true;
  #   theme = {
  #     package = pkgs.adw-gtk3;
  #     name = "adw-gtk3-dark";
  #   };
  #   iconTheme = {
  #     package = pkgs.adwaita-icon-theme;
  #     name = "Adwaita";
  #   };
  # };

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
    bitwarden-cli
    fastfetch
    nwg-look
    kdePackages.gwenview
    kdePackages.okular
    kdePackages.qtwayland
    mpv
    yt-dlp
    signal-desktop
    azure-cli
    pavucontrol
    btop
    grim
    slurp
    rofi-wayland
    rofimoji
    cliphist
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
    foot
    minisign
    unzip
    lm_sensors
    sshfs
    python312Packages.python-lsp-server
    gopls
    anki
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
    ghidra-bin
    sequoia
    sccache
    awscli2
    lldb
    (cutter.withPlugins (p: with p; [
      rz-ghidra
      jsdec
      sigdb
    ]))
    ida-free
    patchelf
    radare2
    p7zip
    qbittorrent
  ];

  programs.waybar.enable = true;
  programs.feh.enable = true;

  services.mako = {
    enable = true;
    backgroundColor = "#1a1a1a";
    defaultTimeout = 5000;
    borderSize = 0;
    borderRadius = 10;
    font = "DejaVu Sans Mono 11";
    padding = "10";
    textColor = "#ffffff";
    extraConfig = ''
      [urgency=high]
      background-color=#c00000
      border-color=#ff0000
    '';
  };

  xdg.configFile = {
    rofi.source = ../rofi;
    waybar.source = ../waybar;
    mpv.source = ../mpv;
  };

  programs.newsboat = {
    enable = true;
    extraConfig = ''
      urls-source "miniflux"
      miniflux-url "https://rss.cything.io/"
      miniflux-login "cy"
      miniflux-passwordfile /run/secrets/newsboat/miniflux
    '';
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
    SCCACHE_REGION = "earth";
    SCCACHE_ENDPOINT = "https://sccache.s3.cy7.sh";
    SCCACHE_ALLOW_CORE_DUMPS = "true";
    SCCACHE_S3_USE_SSL = "true";
    SCCACHE_CACHE_MULTIARCH = "true";
    SCCACHE_LOG_LEVEL = "warn";
    AWS_DEFAULT_REGION = "earth";
    AWS_ENDPOINT_URL = "https://s3.cy7.sh";
    AWS_ACCESS_KEY_ID = "$(cat /run/secrets/aws/key_id)";
    AWS_SECRET_ACCESS_KEY = "$(cat /run/secrets/aws/key_secret)";
  };
}
