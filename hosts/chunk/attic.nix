{ config, ... }:
{
  services.atticd = {
    enable = true;

    environmentFile = config.sops.secrets."attic/env".path;

    settings = {
      listen = "[::]:8090";
      api-endpoint = "https://cache.cy7.sh/";
      allowed-hosts = [ "cache.cy7.sh" ];
      require-proof-of-possession = false;
      compression.type = "zstd";
      database.url = "postgresql:///atticd?host=/run/postgresql";

      storage = {
        type = "s3";
        region = "auto";
        bucket = "attic";
        endpoint = "https://e3e97aac307d106a7becea43cef8fcbd.r2.cloudflarestorage.com";
      };

      garbage-collection = {
        default-retention-period = "2 weeks";
      };
    };
  };

  services.caddy.virtualHosts."cache.cy7.sh".extraConfig = ''
    import common
    reverse_proxy localhost:8090
  '';
}
