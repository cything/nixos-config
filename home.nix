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
    pkgs.delta
    pkgs.borgbackup
    pkgs.rclone
  ];

  home.file = {
    ".zshrc".source = ./zshrc;
    ".p10k.zsh".source = ./p10k.zsh;
    ".config/sway".source = ./sway;
    ".config/nvim".source = ./nvim;
    ".config/aerc".source = ./aerc;
    ".config/git".source = ./git;
    ".config/i3status-rust".source = ./i3status-rust;
    ".config/kitty".source = ./kitty;
    ".config/mako".source = ./mako;
    ".config/rofi".source = ./rofi;
    ".config/tmux".source = ./tmux;
    ".config/waybar".source = ./waybar;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;
}
