{ pkgs, ... }:
{
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      flake-registry = "";
    };
    channel.enable = false;
    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };
    gc = {
      automatic = true;
      dates = "19:00";
      persistent = true;
      options = "--delete-older-than 14d";
    };
  };
  time.timeZone = "America/Toronto";
  networking.firewall.logRefusedConnections = false;

  # this is true by default and mutually exclusive with
  # programs.nix-index
  programs.command-not-found.enable = false;
  programs.nix-index.enable = false;

  users.users.yt.shell = pkgs.zsh;
  programs.zsh.enable = true;

  # needed for zsh.enableCompletion to work
  environment.pathsToLink = [ "/share/zsh" ];

  # see journald.conf(5)
  services.journald.extraConfig = "MaxRetentionSec=2d";
}
