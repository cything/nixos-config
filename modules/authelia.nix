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
              domain = "*.cy7.sh";
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
        identity_providers.oidc.claims_policies = {
          # https://github.com/karakeep-app/karakeep/issues/410
          # https://www.authelia.com/integration/openid-connect/openid-connect-1.0-claims/#restore-functionality-prior-to-claims-parameter
          karakeep.id_token = [ "email" ];
        };
        identity_providers.oidc.clients = [
          {
            client_id = "4EIrpRb9rnwHWjYWvlz2gYrtTmoOLF1D5gqXw28BvmOS0f-9T2p4CFwuctf4Co1hkpo2sd4Y";
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
            token_endpoint_auth_method = "client_secret_basic";
          }
          {
            client_id = "_kuUEYxyfXjInJCniwugpw2Qn6iI-YW24NOkHZG~63BAhnAACDZ.xsLqOdGghj2DNZxXR0sU";
            client_name = "Forgejo";
            client_secret = "$argon2id$v=19$m=65536,t=3,p=4$O2O5r/7A8hc4EMvernQ4Dw$YOVqtwY3jv0HlcxmviPq2CRnD7Dw85V9KDtTSUQE7bA";
            public = false;
            authorization_policy = "two_factor";
            redirect_uris = [
              "https://git.cy7.sh/user/oauth2/authelia/callback"
            ];
            scopes = [ "openid" "profile" "email" ];
            userinfo_signed_response_alg = "none";
            token_endpoint_auth_method = "client_secret_basic";
          }
          {
            client_id = "b_ITCG0uNzy9lZ5nVC~Ny5R35te8I3hoQW1uraCbdxeiE9VuiCIelMmZZ7dAZLg_anTUWSQG";
            client_name = "HedgeDoc";
            client_secret = "$argon2id$v=19$m=65536,t=3,p=4$MFSXW3gjIZf0M3e8s8RJCg$6KWwksJe2vdUebPEdYc0Zy88fzGcHPrbStcqkiXl+Hg";
            public = false;
            authorization_policy = "two_factor";
            redirect_uris = [
              "https://pad.cy7.sh/auth/oauth2/callback"
            ];
            scopes = [ "openid" "profile" "email" ];
            userinfo_signed_response_alg = "none";
            grant_types = [ "refresh_token" "authorization_code" ];
            response_types = [ "code" ];
            response_modes = [ "form_post" "query" "fragment" ];
            audience = [];
            token_endpoint_auth_method = "client_secret_post";
          }
          {
            client_id = "0SbsGvw5APYJ4px~dv38rCVgXtK2XWrF1QvyuaFz48cgsNm-rAXkSgNOctfxS21IWOFSfsm5";
            client_name = "Karakeep";
            client_secret = "$pbkdf2-sha512$310000$4UanDZq.6oholJW3CmKwtQ$9e3hqR8qGU4LoneR/Y9jtJTx0iSzATI4iXymrs8QrmGw4JY1BPF4.IJ9Jbc.8cikU4qpfUIFO6r2dG7JHznCnw";
            public = false;
            authorization_policy = "two_factor";
            redirect_uris = [ "https://keep.cy7.sh/api/auth/callback/custom" ];
            scopes = [ "openid" "profile" "email" ];
            userinfo_signed_response_alg = "none";
            claims_policy = "karakeep";
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
