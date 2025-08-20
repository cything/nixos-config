{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./common.nix
    ../kitty.nix
  ];

  home = {
    username = "yt";
    homeDirectory = "/home/yt";
    stateVersion = "25.05";
  };
  programs.home-manager.enable = true;

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 23;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages = with pkgs; lib.flatten [
    bitwarden-desktop
    fastfetch
    mpv
    signal-desktop
    btop
    jq
    usbutils
    calibre
    tor-browser
    wtype
    rclone
    gnumake
    unzip
    anki-bin
    gdb
    qbittorrent
    minio-client
    jujutsu
    keepassxc
    (ungoogled-chromium.override {
        enableWideVine = true;
      })
    (with llvmPackages; [
        clangUseLLVM
        compiler-rt
        libllvm
      ])
  ];

  home.sessionVariables = {
    # to make ghidra work on xwayland
    _JAVA_AWT_WM_NONREPARENTING = 1;
  };

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
      vscode-langservers-extracted
      typescript-language-server
    ];
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

  programs.firefox.enable = true;
}
