{ config, ... }:
{
  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.sops.secrets."miniflux/env".path;
    config = {
      PORT = 8080;
      BASE_URL = "https://rss.cy7.sh";
      FORCE_REFRESH_INTERVAL = 0; # don't rate limit me
    };
  };

  services.caddy.virtualHosts."rss.cy7.sh".extraConfig = ''
    import common
    import authelia
    reverse_proxy localhost:8080
  '';
}
