{ config, lib, ... }:
let
  cfg = config.my.soju;
in
{
  options.my.soju = {
    enable = lib.mkEnableOption "soju";
  };

  config = lib.mkIf cfg.enable {
    services.soju = {
      enable = true;
      # should be fine since caddy will provide TLS
      listen = [ "irc+insecure://127.0.0.1:6667" ];
      hostName = "soju.cy7.sh";
    };

    services.caddy.virtualHosts."soju.cy7.sh".extraConfig = ''
      import common
      reverse_proxy 127.0.0.1:6667
    '';
  };
}
