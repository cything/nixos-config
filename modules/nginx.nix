{ config, lib, ...}:
  let
    cfg = config.my.nginx;
  in
  {
  options.my.nginx = {
    enable = lib.mkEnableOption "nginx";
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedZstdSettings = true;
      recommendedProxySettings = true;

      # HSTS for all domains
      appendHttpConfig = ''
        map $scheme $hsts_header {
            https   "max-age=31536000; includeSubdomains; preload";
        }
        add_header Strict-Transport-Security $hsts_header;
      '';
    };
  };
}
