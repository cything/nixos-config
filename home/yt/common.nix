{ pkgs, ... }:
{
  imports = [
    ../tmux.nix
    ../zsh
  ];

  home.sessionVariables = {
    "EDITOR" = "nvim";
  };

  home.packages = with pkgs; [
    man-pages
    man-pages-posix
    man
    man-db
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
    settings = {
      user.name = "cy";
      user.email = "cy@cy7.sh";
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
          insteadOf = [
            # "https://github.com/"
            "github:"
            "gh:"
          ];
        };
      };
    };
  };
  programs.difftastic = {
    enable = true;
    git.enable = true;
  };

  programs.ripgrep.enable = true;
  # programs.man.generateCaches = true; # slows down eval
  programs.fd.enable = true;
  news.display = "silent";
}
