{ ... }:
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
}
