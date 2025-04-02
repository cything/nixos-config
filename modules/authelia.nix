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
        webauthn = {
          enable_passkey_login = true;
        };
        identity_providers.oidc.clients = [
          {
            client_id = "immich";
            client_name = "immich";
            client_secret = "$argon2id$v=19$m=65536,t=3,p=4$Vny2G8EbSPafSwnIuq2Zkg$eF2om4WDEaqCFmrAG27h2mYl+cXxXyttPJ7gaPLs+f8";
            public = false;
            authorization_policy = "two_factor";
            redirect_uris = [
              "https://photos.cy7.sh/auth/login"
              "https://photos.cy7.sh/user-settings"
              "app.immich:///oauth-callback"
            ];
            scopes = [ "openid" "profile" "email" ];
            userinfo_signed_response_alg = "none";
          }
        ];
      };
      secrets = {
        sessionSecretFile = getSecret "authelia/session";
        storageEncryptionKeyFile = getSecret "authelia/storage";
        jwtSecretFile = getSecret "authelia/jwt";
        oidcHmacSecretFile = getSecret "authelia/hmac";
        oidcIssuerPrivateKeyFile = getSecret "authelia/oidc_private";
      };
    };

    sops.secrets = {
      "authelia/jwt" = sopsConfig;
      "authelia/storage" = sopsConfig;
      "authelia/session" = sopsConfig;
      "authelia/hmac" = sopsConfig;
      "authelia/oidc_private" = sopsConfig;
    };

    services.caddy.virtualHosts.${domain}.extraConfig = ''
      import common
      reverse_proxy localhost:9091
    '';
  };
}