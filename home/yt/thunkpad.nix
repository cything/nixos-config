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

  home.packages =
    with pkgs;
    lib.flatten [
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
        commandLineArgs = [
          "--ozone-platform-hint=auto"
          "--enable-features=TouchpadOverscrollHistoryNavigation"
        ];
      })
      (with llvmPackages; [
        clangUseLLVM
        compiler-rt
        libllvm
      ])
      (python313.withPackages (
        p: with p; [
          python-lsp-server
          pip
          virtualenv
        ]
      ))
      (with kdePackages; [
        gwenview
        okular
        kservice
      ])
      spotify

      (texliveSmall.withPackages (
        ps: with ps; [
          xcolor
        ]
      ))
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
    matchBlocks."*" = {
      addKeysToAgent= "yes";
    };
  };

  programs.firefox.enable = true;

  xdg.configFile = {
    mpv.source = ../mpv;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "okular.desktop" ];
      "image/*" = [ "gwenview.desktop" ];
      "video/*" = [ "mpv" ];
      "text/html" = [ "chromium-browser.desktop" ];
      "x-scheme-handler/http" = [ "chromium-browser.desktop" ];
      "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
    };
  };

  programs.pandoc = {
    enable = true;
    defaults.pdf-engine = "xelatex";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
