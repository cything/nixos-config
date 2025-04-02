{ ... }:
{
  imports = [
    ./backup.nix
    ./caddy.nix
    ./roundcube.nix
    ./zipline.nix
    ./containerization.nix
    ./vaultwarden.nix
    ./searx.nix
    ./attic.nix
    ./authelia.nix
  ];
}
