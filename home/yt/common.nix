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

  programs.zoxide.options = [ "--cmd cd" ];
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
  programs.eza.enable = true;
  programs.neovim.enable = true;
  programs.git = {
    enable = true;
    userName = "cy";
    userEmail = "hi@cything.io";
    delta.enable = true;
    extraConfig = {
      init = {
        "defaultBranch" = "main";
      };
    };
  };
}
