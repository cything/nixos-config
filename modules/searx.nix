{
  config,
  lib,
  ...
}:
let
  cfg = config.my.searx;
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
      redisCreateLocally = true; # required for limiter
      limiterSettings = {
        real_ip = {
          x_for = 1;
          ipv4_prefix = 32;
          ipv6_prefix = 56;
        };
        botdetection.ip_lists.pass_ip = [
          "100.121.152.86"
          "100.66.32.54"
        ];
        link_token = true;
      };
    };

    services.caddy.virtualHosts."x.cy7.sh".extraConfig = ''
      import common
      reverse_proxy 127.0.0.1:8090
    '';
  };
}
