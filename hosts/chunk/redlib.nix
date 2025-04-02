{ ... }:
{
  services.redlib = {
    enable = true;
    port = 8087;
    address = "127.0.0.1";
    settings = {
      # settings are just env vars
      REDLIB_ENABLE_RSS = "on";
      REDLIB_ROBOTS_DISABLE_INDEXING = "on";
    };
  };

  services.caddy.virtualHosts."red.cy7.sh".extraConfig = ''
    import common
    import authelia
    reverse_proxy localhost:8087
  '';
}
