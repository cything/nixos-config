{ config, ... }:
{
  services.atticd = {
    enable = true;

    environmentFile = config.sops.secrets."attic/env".path;

    settings = {
      listen = "[::]:8090";
      api-endpoint = "https://cache.cything.io/";
      allowed-hosts = [ "cache.cything.io" ];
      require-proof-of-possession = false;
      compression.type = "zstd";
      database.url = "postgresql:///atticd?host=/run/postgresql";

      storage = {
        type = "local";
        path = "/mnt/attic";
      };

      garbage-collection = {
        default-retention-period = "3 months";
      };

      chunking = {
        nar-size-threshold = 128 * 1024 * 1024;
        min-size = 64 * 1024 * 1024;
        avg-size = 128 * 1024 * 1024;
        max-size = 256 * 1024 * 1024;
      };
    };
  };
}
