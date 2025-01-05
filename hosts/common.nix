{ ... }:
{
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      flake-registry = "";
      trusted-users = [ "root" "@wheel" "harmonia" ];
      trusted-public-keys = [ "cache.cything.io:4NhyCpZuroY7+JP18m1wkAgJGb6WL0jrtx2Bgrvdtow=" ];
      substituters = [ "https://cache.cything.io/" ];
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
    extraOptions = ''
	    builders-use-substitutes = true
	  '';

  };
  time.timeZone = "America/Toronto";
  networking.firewall.logRefusedConnections = false;

  # this is true by default and mutually exclusive with
  # programs.nix-index
  programs.command-not-found.enable = false;
  programs.nix-index.enable = false; # set above to false to use this

  # see journald.conf(5)
  services.journald.extraConfig = "MaxRetentionSec=2d";
}
