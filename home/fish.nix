{pkgs, ...}: {
  programs.fish = {
    enable = true;
    plugins = [
    {
      name = "colored-man-pages";
      src = pkgs.fetchFromGitHub {
        owner = "PatrickF1";
        repo = "colored_man_pages.fish";
        rev = "f885c2507128b70d6c41b043070a8f399988bc7a";
        hash = "sha256-ii9gdBPlC1/P1N9xJzqomrkyDqIdTg+iCg0mwNVq2EU=";
      };
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
  };

  programs.fzf = {
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enableFishIntegration = true;
  };

  programs.eza = {
    enableFishIntegration = true;
  };
}
