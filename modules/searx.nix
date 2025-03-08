{
  config,
  lib,
  ...
}:
let
  cfg = config.my.searx;
  sockPath = "/run/searx/searx.sock";
in
{
  options.my.searx = {
    enable = lib.mkEnableOption "searx";
  };

  config = lib.mkIf cfg.enable {
    services.searx = {
      enable = true;
      runInUwsgi = true;
      uwsgiConfig = {
        disable-logging = true;
        http = "127.0.0.1:8090";
      };
      settings = {
        # get secret from env
        server.secret_key = "@SEARX_SECRET_KEY@";
      };
      environmentFile = config.sops.secrets."searx/env".path;
    };

    services.caddy.virtualHosts."x.cy7.sh".extraConfig = ''
      import common
      reverse_proxy 127.0.0.1:8090
    '';
  };
}