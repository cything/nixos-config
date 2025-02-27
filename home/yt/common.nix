{ pkgs, ... }:
{
  imports = [
    ../tmux.nix
    ../zsh
    ../nixvim
  ];

  home.sessionVariables = {
    "EDITOR" = "nvim";
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
  programs.git = {
    enable = true;
    userName = "cy";
    userEmail = "cy@cy7.sh";
    delta = {
      enable = false;
      options = {
        navigate = true;
      };
    };
    difftastic.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true; # assume -u on first push
      pull = {
        rebase = true;
        autostash = true;
      };
      merge = {
        tool = "vimdiff";
        keepBackup = false;
        prompt = false;
      };
      rebase = {
        stat = true;
        autoStash = true;
        autoSquash = true;
        updateRefs = true;
      };
      help.autocorrect = 1;
      "mergetool \"vimdiff\"".cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
    };
  };
  programs.ripgrep.enable = true;
  # programs.man.generateCaches = true; # slows down eval
  programs.fd.enable = true;
  news.display = "silent";
}
