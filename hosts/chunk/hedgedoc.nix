{...}: {
  services.hedgedoc = {
    enable = true;
    environmentFile = "/run/secrets/hedgedoc";
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
