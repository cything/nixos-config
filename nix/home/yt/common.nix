{...}: {
  imports = [
    ./tmux.nix
    ./zsh
  ];

  home.sessionVariables = {
    "EDITOR" = "nvim";
  };
}
