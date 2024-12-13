{
  config,
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}: {
  home = {
    username = "yt";
    homeDirectory = "/home/yt";
    stateVersion = "24.05";
  };
  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-qt;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern";
    };
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  home.sessionVariables = {
    ANKI_WAYLAND = "1";
  };

  programs.git = {
    enable = true;
    userName = "cy";
    userEmail = "hi@cything.io";
    delta.enable = true;
  };

  programs.neovim.enable = true;

  home.packages = with pkgs; [
    firefox
    inputs.master.legacyPackages.${system}.ungoogled-chromium
    # ungoogled-chromium
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
    sshfs
    nextcloud-client
    python312Packages.python-lsp-server
    gopls
    anki-bin
  ];

  programs.waybar.enable = true;
  programs.feh.enable = true;
}
