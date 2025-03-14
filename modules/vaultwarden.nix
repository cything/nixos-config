{
  config,
  lib,
  ...
}:
let
  cfg = config.my.vaultwarden;
in
{
  options.my.vaultwarden = {
    enable = lib.mkEnableOption "vaultwarden";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "https://pass.cy7.sh";
    };
  };

  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      environmentFile = config.sops.secrets."vaultwarden/env".path;
      config = {
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = "8081";
        DATABASE_URL = "postgresql://vaultwarden:vaultwarden@127.0.0.1:5432/vaultwarden";
        EXPERIMENTAL_CLIENT_FEATURE_FLAGS = "fido2-vault-credentials,ssh-agent,ssh-key-vault-item,autofill-v2";
        DOMAIN = cfg.domain;
      };
    };
  };
}
