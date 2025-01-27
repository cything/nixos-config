{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.caddy;
  commonExtraConfig = ''
    encode zstd gzip
    header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
  '';
in
{
  options.my.caddy = {
    enable = lib.mkEnableOption "caddy reverse proxy";
    acmeCa = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      logFormat = lib.mkForce "level INFO";
      acmeCa = "https://acme-v02.api.letsencrypt.org/directory";
    };
  };
}
