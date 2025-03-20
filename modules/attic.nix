{
  config,
  lib,
  ...
}:
let
  cfg = config.my.attic;
in
{
  options.my.attic = {
    enable = lib.mkEnableOption "attic";
  };

  config = lib.mkIf cfg.enable {
    services.atticd = {
      enable = true;
      environmentFile = config.sops.secrets."attic/env".path;
      settings = {
        listen = "[::]:8091";
        api-endpoint = "https://cache.cy7.sh/";
        allowed-hosts = [ "cache.cy7.sh" "cdn.cy7.sh" ];
        require-proof-of-possession = false;
        compression = {
          type = "none";
          level = 3;
        };
        database.url = "postgresql:///atticd?host=/run/postgresql";

        storage = {
          type = "s3";
          region = "us-east-1";
          bucket = "attic";
          # attic must be patched to never serve pre-signed s3 urls directly
          # otherwise it will redirect clients to this localhost endpoint
          endpoint = "http://127.0.0.1:3900";
        };

        garbage-collection = {
          default-retention-period = "1 month";
        };

        chunking = {
          # disable chunking since garage does its own
          nar-size-threshold = 0;
          # defaults
          min-size = 16384;
          avg-size = 65536;
          max-size = 262144;
        };
      };
    };

    systemd.services.atticd = {
      requires = [ "garage.service" ];
      after = [ "garage.service" ];
      environment = {
        RUST_LOG = "INFO";
      };
    };

    services.caddy.virtualHosts."cache.cy7.sh" = {
      serverAliases = [ "cdn.cy7.sh" ];
      extraConfig = ''
        import common
        reverse_proxy localhost:8091
      '';
    };
  };
}
