{ config, lib, ... }:
let
  cfg = config.my.karakeep;
in
{
  options.my.karakeep = {
    enable = lib.mkEnableOption "karakeep";
    dataDir = lib.mkOption {
      type = lib.types.path;
    };
    port = lib.mkOption {
      default = 3002;
      description = "port for the web service";
      type = lib.types.port;
    };
    domain = lib.mkOption {
      default = "keep.cy7.sh";
      type = lib.types.str;
    };
    environmentFile = lib.mkOption {
      default = config.sops.secrets."karakeep/env".path;
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      karakeep-web = {
        image = "ghcr.io/karakeep-app/karakeep:release";
        pull = "newer";
        volumes = [ "${cfg.dataDir}:/data" ];
        ports = [ "${toString cfg.port}:3000"];
        dependsOn = [
          "karakeep-chrome"
          "karakeep-meilisearch"
        ];
        environment = {
          MEILI_ADDR = "http://karakeep-meilisearch:7700";
          BROWSER_WEB_URL = "http://karakeep-chrome:9222";
          DATA_DIR =  "/data";
          NEXTAUTH_URL = "https://${cfg.domain}";
          DISABLE_PASSWORD_AUTH = "true";
          OAUTH_WELLKNOWN_URL = "https://auth.cy7.sh/.well-known/openid-configuration";
          OAUTH_CLIENT_ID = "0SbsGvw5APYJ4px~dv38rCVgXtK2XWrF1QvyuaFz48cgsNm-rAXkSgNOctfxS21IWOFSfsm5";
          OAUTH_PROVIDER_NAME = "Authelia";
          OAUTH_ALLOW_DANGEROUS_EMAIL_ACCOUNT_LINKING = "true";
        };
        # needs NEXTAUTH_SECRET
        environmentFiles = [ "${cfg.environmentFile}" ];
      };

      karakeep-chrome = {
        image = "ghcr.io/zenika/alpine-chrome:latest";
        pull = "newer";
        cmd = [
          "--no-sandbox"
          "--disable-gpu"
          "--disable-dev-shm-usage"
          "--remote-debugging-address=0.0.0.0"
          "--remote-debugging-port=9222"
          "--hide-scrollbars"
        ];
      };

      karakeep-meilisearch = {
        image = "getmeili/meilisearch:latest";
        volumes = [ "meilisearch:/meili_data" ];
        environment = {
          MEILI_NO_ANALYTICS = "true";
        };
        # needs MEILI_MASTER_KEY
        environmentFiles = [ "${cfg.environmentFile}" ];
      };
    };

    services.caddy.virtualHosts.${cfg.domain}.extraConfig = ''
      import common
      reverse_proxy localhost:${toString cfg.port}
    '';
  };
}