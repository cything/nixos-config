{ pkgs, ... }:
{
  users.users.yt = {
    isNormalUser = true;
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # needed for zsh.enableCompletion to work
  environment.pathsToLink = [ "/share/zsh" ];
}
