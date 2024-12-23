{ ... }:
{
  programs.fish = {
    enable = true;
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

    shellInit = ''
      set fish_greeting
    '';

    functions = {
      fish_prompt = ''
        set -l last_status $status
        set -l normal (set_color normal)
        set -l status_color (set_color brgreen)
        set -l cwd_color (set_color $fish_color_cwd)
        set -l vcs_color (set_color brpurple)
        set -l prompt_status ""

        # Since we display the prompt on a new line allow the directory names to be longer.
        set -q fish_prompt_pwd_dir_length
        or set -lx fish_prompt_pwd_dir_length 0

        # Color the prompt differently when we're root
        set -l suffix '❯'
        if functions -q fish_is_root_user; and fish_is_root_user
            if set -q fish_color_cwd_root
                set cwd_color (set_color $fish_color_cwd_root)
            end
            set suffix '#'
        end

        # Color the prompt in red on error
        if test $last_status -ne 0
            set status_color (set_color $fish_color_error)
            set prompt_status $status_color "[" $last_status "]" $normal
        end

        echo -s (prompt_login) ' ' $cwd_color (prompt_pwd) $vcs_color (fish_vcs_prompt) $normal ' ' $prompt_status
        echo -n -s $status_color $suffix ' ' $normal
      '';

    };
  };

  programs.fzf.enableFishIntegration = true;
  programs.zoxide.enableFishIntegration = true;
  programs.eza.enableFishIntegration = true;
  programs.nix-index.enableFishIntegration = true;
}
