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
        CORE_PORT = 3001;
        DATASOURCE_TYPE = "s3";
        DATASOURCE_S3_ENDPOINT = "e3e97aac307d106a7becea43cef8fcbd.r2.cloudflarestorage.com";
        DATASOURCE_S3_BUCKET = "zipline";
        DATASOURCE_S3_REGION = "auto";
        DATASOURCE_S3_USE_SSL = "true";
        DATASOURCE_S3_FORCE_S3_PATH = "false";
        FEATURES_THUMBNAILS = "true";
        EXIF_REMOVE_GPS = "true";
        CHUNKS_CHUNKS_SIZE = "50mb";
        CHUNKS_MAX_SIZE = "95mb";
        FEATURES_OAUTH_REGISTRATION = "true";
      };
      environmentFiles = [ config.sops.secrets."zipline/env".path ];
    };

    services.caddy.virtualHosts."host.cy7.sh".extraConfig = ''
      import common
      reverse_proxy 127.0.0.1:3001
    '';
  };
}
