{ config, ... }:
{
  services.hedgedoc = {
    enable = true;
    environmentFile = config.sops.secrets."hedgedoc/env".path;
    settings = {
      db = {
        username = "hedgedoc";
        database = "hedgedoc";
        host = "/run/postgresql";
        dialect = "postgresql";
      };
      port = 8085;
      domain = "pad.cy7.sh";
      allowEmailRegister = false;
      protocolUseSSL = true;
    };
  };

  services.caddy.virtualHosts."pad.cy7.sh".extraConfig = ''
    import common
    reverse_proxy localhost:8085
  '';
}
