{config, ...}: {
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
      domain = "pad.cything.io";
      allowEmailRegister = false;
      protocolUseSSL = true;
    };
  };
}
