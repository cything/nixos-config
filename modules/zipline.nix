{
  config,
  lib,
  ...
}:
let
  cfg = config.my.zipline;
in
{
  options.my.zipline = {
    enable = lib.mkEnableOption "zipline";
  };

  config = lib.mkIf cfg.enable {
    services.zipline = {
      enable = true;
      settings = {
        CORE_HOSTNAME = "127.0.0.1";
        CORE_PORT = 3001;
        DATASOURCE_TYPE = "s3";
        DATASOURCE_S3_ENDPOINT = "https://e3e97aac307d106a7becea43cef8fcbd.r2.cloudflarestorage.com";
        DATASOURCE_S3_BUCKET = "zipline";
        DATASOURCE_S3_REGION = "auto";
      };
      environmentFiles = [ config.sops.secrets."zipline/env".path ];
    };

    services.caddy.virtualHosts."host.cy7.sh".extraConfig = ''
      import common
      reverse_proxy 127.0.0.1:3001
    '';
  };
}
