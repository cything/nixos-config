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
    defaultKeymap = "emacs";

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
    initExtra = ''
      #disable control+s to pause terminal
      unsetopt FLOW_CONTROL
      source ${./p10k.zsh}
    '';
    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
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
      "nrs" = "sudo nixos-rebuild switch --flake .";
      "nrt" = "sudo nixos-rebuild test --flake .";
      "hrs" = "home-manager switch --flake .";
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
    sessionVariables = {
      "FZF_DEFAULT_COMMAND" = "rg";
    };
  };

  programs.fzf.enableZshIntegration = true;
  programs.zoxide.enableZshIntegration = true;
  programs.eza.enableZshIntegration = true;
  programs.nix-index.enableZshIntegration = true;
}
