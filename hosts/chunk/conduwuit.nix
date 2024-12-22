{ pkgs, ... }:
{
  services.conduwuit = {
    enable = true;
    package = pkgs.callPackage ../../pkgs/conduwuit.nix { };
    settings.global = {
      port = [ 8448 ];
      server_name = "cything.io";
      allow_check_for_updates = true;
    };
  };
}
