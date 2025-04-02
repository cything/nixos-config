{
  config,
  lib,
  ...
}:
let
  cfg = config.my.authelia;
  getSecret = path: config.sops.secrets.${path}.path;
  sopsConfig = {
    sopsFile = ../secrets/services/authelia.yaml;
    owner = "authelia-main";
  };
  domain = "auth.cy7.sh";
  varPath = "/var/lib/authelia-main";
in
{
  options.my.authelia = {
    enable = lib.mkEnableOption "authelia";
  };

  config = lib.mkIf cfg.enable {
    services.authelia.instances.main = {
      enable = true;
      settings = {
        theme = "dark";
        default_2fa_method = "webauthn";
        log.level = "info";
        log.format = "text";
        server = {
          disable_healthcheck = true;
          endpoints.authz.forward-auth.implementation = "ForwardAuth";
        };
        authentication_backend.file.path = "${varPath}/users_database.yaml";
        access_control = {
          default_policy = "deny";
          rules = [
            {
              domain = "red.cy7.sh";
              policy = "one_factor";
            }
          ];
        };
        session.cookies = [{
          domain = "cy7.sh";
          authelia_url = "https://${domain}";
        }];
        storage.local.path = "${varPath}/db.sqlite3";
        notifier.filesystem.filename = "${varPath}/notifications.txt";
      };
      secrets = {
        sessionSecretFile = getSecret "authelia/session";
        storageEncryptionKeyFile = getSecret "authelia/storage";
        jwtSecretFile = getSecret "authelia/jwt";
      };
    };

    sops.secrets = {
      "authelia/jwt" = sopsConfig;
      "authelia/storage" = sopsConfig;
      "authelia/session" = sopsConfig;
    };

    services.caddy.virtualHosts.${domain}.extraConfig = ''
      import common
      reverse_proxy localhost:9091
    '';
  };
}