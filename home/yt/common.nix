{ pkgs, ... }:
{
  imports = [
    ../tmux.nix
    ../zsh
  ];

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      flake-registry = "";
      trusted-users = [ "root" "@wheel" ];
      trusted-public-keys = [ "central:uWhjva6m6dhC2hqNisjn2hXGvdGBs19vPkA1dPEuwFg=" ];
      substituters = [ "https://cache.cything.io/central" ];
    };
    gc = {
      automatic = true;
      frequency = "19:00";
      persistent = true;
      options = "--delete-older-than 14d";
    };
    extraOptions = ''
	    builders-use-substitutes = true
	  '';
    package = pkgs.nix;
  };

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
    attic-client
    bottom
    btop
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
