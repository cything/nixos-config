{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };
    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "brackets" ];
    };
    autocd = true;
    defaultKeymap = "viins";

    initExtraFirst = ''
      if [[ -r "''\${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''\${(%):-%n}.zsh" ]]; then
        source "''\${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''\${(%):-%n}.zsh"
      fi
    '';

    history = {
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      save = 10000;
      size = 10000;
      append = true;
    };
    historySubstringSearch = {
      enable = true;
      searchUpKey = "^p";
      searchDownKey = "^n";
    };

    prezto = {
      enable = true;
      caseSensitive = false;
    };

    initExtra = ''
      # disable control+s to pause terminal
      unsetopt FLOW_CONTROL

      # useful emacs mode bindings
      bindkey -M viins "^E" end-of-line
      bindkey -M viins "^A" beginning-of-line
      bindkey -M viins "^B" backward-char

      # accept one word completion
      bindkey -M viins "^S" forward-word

      # fzf-tab stuff
      # set description format to enable group support
      zstyle ':completion:*:descriptions' format '[%d]'
      # set list-colors to enable filename colorizing
      zstyle ':completion:*' list-colors ''\${(s.:.)LS_COLORS}
      # force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
      zstyle ':completion:*' menu no
      # preview directory's content with eza when completing cd
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      # switch group using `<` and `>`
      zstyle ':fzf-tab:*' switch-group '<' '>'

      source ${./p10k.zsh}
    '';
    plugins = with pkgs; [
      {
        name = "powerlevel10k";
        src = zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "fzf-tab";
        src = zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.zsh";
      }
    ];
    shellAliases = {
      "vi" = "nvim";
      "vim" = "nvim";
      "t" = "tmux";
      "tl" = "tmux list-sessions";
      "ta" = "tmux new-session -A -s";
      "se" = "sudoedit";
      "s" = "sudo";
      "nrs" = "sudo nixos-rebuild switch -L --flake .";
      "nrt" = "sudo nixos-rebuild test -L --flake .";
      "hrs" = "home-manager switch -L --flake .";
      "g" = "git";
      "ga" = "git add";
      "gaa" = "git add --all";
      "gb" = "git branch";
      "gc" = "git commit --verbose";
      "gcmsg" = "git commit --message";
      "gd" = "git diff";
      "gdca" = "git diff --cached";
      "gds" = "git diff --staged";
      "gl" = "git log --stat";
      "glg" = "git log --graph";
      "glga" = "git log --graph --decorate --all";
      "glo" = "git log --oneline --decorate";
      "gp" = "git push";
      "gr" = "git remote";
      "gra" = "git remote add";
      "grv" = "git remote --verbose";
      "gs" = "git status --short";
      "gss" = "git status";
    };
  };

  programs.fzf.enableZshIntegration = true;
  programs.zoxide.enableZshIntegration = true;
  programs.eza.enableZshIntegration = true;
  programs.nix-index.enableZshIntegration = false;
  programs.direnv.enableZshIntegration = false;
}
