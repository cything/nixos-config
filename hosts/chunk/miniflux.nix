{ config, ... }:
{
  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.sops.secrets."miniflux/env".path;
    config = {
      PORT = 8080;
      BASE_URL = "https://rss.cything.io";
      FORCE_REFRESH_INTERVAL = 0; # don't rate limit me
    };
  };
}
