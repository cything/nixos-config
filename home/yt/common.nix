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
  programs.fzf = {
    enable = true;
    defaultCommand = "rg";
  };
  programs.zoxide.enable = true;
  programs.eza.enable = true;
  programs.neovim.enable = true;
  programs.git = {
    enable = true;
    userName = "cy";
    userEmail = "hi@cything.io";
    delta = {
      enable = true;
      options = {
        navigate = true;
      };
    };
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true; # assume -u on first push
      pull = {
        rebase = true;
        autostash = true;
      };
      merge.tool = "vimdiff";
      rebase = {
        stat = true;
        autoStash = true;
        autoSquash = true;
        updateRefs = true;
      };
      help.autocorrect = 1;
      mergetool = {
        prompt = false;
        path = "nvim-open";
      };
    };
  };
  programs.ripgrep.enable = true;
  programs.man.generateCaches = true;
}
