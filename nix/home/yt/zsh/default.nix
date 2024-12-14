{
  config,
  lib,
  inputs,
  ...
}: {
  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
      strategy = [ "history" "completion" ];
    };
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "brackets" "cursor" ];
    };
    autocd = true;
    defaultKeymap = "emacs";
    antidote = {
      enable = true;
      useFriendlyNames = true; # why not?
      plugins = [
        "zsh-users/zsh-completions"
        "romkatv/powerlevel10k"
        "Aloxaf/fzf-tab"
        "z-shell/zsh-eza"
        "ohmyzsh/ohmyzsh path:plugins/colored-man-pages"
        "ohmyzsh/ohmyzsh path:plugins/git"
      ];
    };
    history = {
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      save = 50000;
      size = 50000;
      append = true;
    };
    historySubstringSearch= {
      enable = true;
      searchUpKey = "^p";
      searchDownKey = "^n";
    };
    initExtra = ''
      source ${./p10k.zsh}
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-prewview 'ls $realpath'
    '';
    shellAliases = {
      "vi" = "nvim";
      "vim" = "nvim";
      "t" = "tmux";
      "tl" = "tmux list-sessions";
      "ta" = "tmux new-session -A -s";
      "se" = "sudoedit";
      "s" = "sudo";
      "nrs" = "sudo nixos-rebuild switch --flake .";
      "nrt" = "sudo nixos-rebuild test --flake .";
      "hrs" = "home-manager switch --flake .";
    };
    sessionVariables = {
      "FZF_DEFAULT_COMMAND" = "rg";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
