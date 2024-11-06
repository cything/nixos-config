{ config, pkgs, ... }:

{
  home.username = "yt";
  home.homeDirectory = "/home/yt";
  home.stateVersion = "24.05";

  home.packages = [
    pkgs.neovim
    pkgs.fzf
    pkgs.eza
    pkgs.gnupg
    pkgs.go
    pkgs.pass
    pkgs.zsh
    pkgs.anki-bin
  ];

  home.file = {
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
}
