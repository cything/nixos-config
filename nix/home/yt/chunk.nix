{
  config,
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./zsh
  ];
  home = {
    username = "yt";
    homeDirectory = "/home/yt";
    stateVersion = "24.05";
  };
  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  programs.git = {
    enable = true;
    userName = "cy";
    userEmail = "hi@cything.io";
    delta.enable = true;
  };

  programs.neovim.enable = true;

  home.packages = with pkgs; [
    fzf
    eza
    zoxide
    delta
    lua-language-server
    vim-language-server
    python312Packages.python-lsp-server
    nixd
    gopls
    bash-language-server
    llvmPackages_19.clang-tools
    rust-analyzer
    yt-dlp
    gnumake
    btop
  ];
}
