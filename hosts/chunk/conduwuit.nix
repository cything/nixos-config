{ ... }:
{
  services.conduwuit = {
    enable = true;
    settings.global = {
      port = [ 8448 ];
      server_name = "cything.io";
      allow_check_for_updates = true;
    };
  };
}
