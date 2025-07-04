{
  config,
  lib,
  ...
}:
let
  cfg = config.my.actual;
in
{
  options.my.actual = {
    enable = lib.mkEnableOption "actual";
    port = lib.mkOption {
      default = 3004;
      type = lib.types.port;
    };
    domain = lib.mkOption {
      default = "actual.cy7.sh";
      type = lib.types.str;
    };
    environmentFile = lib.mkOption {
      default = config.sops.secrets."actual/env".path;
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    services.actual = {
      enable = true;
      settings = {
        allowedLoginMethods = [ "openid" ];
        port = cfg.port;
        hostname = "127.0.0.1";
        openId = {
          discoveryURL = "https://auth.cy7.sh";
          client_id = "Qvd9R2C1PHFJaeVKZceqlFFM8L5dhznqTyCvEtpY6jSgLQjVssubKNRjt0FTY4Fs";
          server_hostname = "https://${cfg.domain}";
          authMethod = "oauth2";
        };
      };
    };
    systemd.services.actual.serviceConfig.EnvironmentFile = cfg.environmentFile;

    services.caddy.virtualHosts.${cfg.domain}.extraConfig = ''
      import common
      reverse_proxy localhost:${toString cfg.port}
    '';
  };
}
