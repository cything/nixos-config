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
          endpoint = "https://s3.cy7.sh";
        };

        garbage-collection = {
          default-retention-period = "1 month";
        };
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
