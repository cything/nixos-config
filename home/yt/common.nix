{ pkgs, ... }:
{
  imports = [
    ../tmux.nix
    ../zsh
  ];

  home.sessionVariables = {
    "EDITOR" = "nvim";
  };

  xdg.configFile = {
    nvim.source = ../nvim;
  };

  home.packages = with pkgs; [
    man-pages
    man-pages-posix
    man
    man-db
  ];
}
