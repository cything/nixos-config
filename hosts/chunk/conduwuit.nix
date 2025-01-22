{ inputs, ... }:
{
  services.conduwuit = {
    enable = true;
    package = inputs.conduwuit.packages.x86_64-linux.static-x86_64-linux-musl-all-features-x86_64-haswell-optimised;
    settings.global = {
      port = [ 8448 ];
      server_name = "cything.io";
      allow_check_for_updates = true;
    };
  };
}
