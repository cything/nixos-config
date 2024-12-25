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

    initExtraFirst = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

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
      source ${./p10k.zsh}

      #disable control+s to pause terminal
      unsetopt FLOW_CONTROL
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
