{...}: {
  services.miniflux = {
    enable = true;
    adminCredentialsFile = "/run/secrets/miniflux";
    config = {
      PORT = 8080;
      BASE_URL = "https://rss.cything.io";
      FORCE_REFRESH_INTERVAL = 0; # don't rate limit me
    };
  };
}
