{ config, ... }:
{
  services.atticd = {
    enable = true;

    environmentFile = config.sops.secrets."attic/env".path;

    settings = {
      listen = "[::]:8090";
      api-endpoint = "https://cache.cything.io/";
      allowed-hosts = [ "cache.cything.io" ];

      jwt = { };

      compression.type = "zstd";
      storage = {
        type = "s3";
        region = "default";
        bucket = "cy7";
        endpoint = "https://e3e97aac307d106a7becea43cef8fcbd.r2.cloudflarestorage.com";
      };
      database.url = "postgresql:///atticd?host=/run/postgresql";

      chunking = {
        nar-size-threshold = 64 * 1024; # 64 KiB
        min-size = 16 * 1024; # 16 KiB
        avg-size = 64 * 1024; # 64 KiB
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };
}
