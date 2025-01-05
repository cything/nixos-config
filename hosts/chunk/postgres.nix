{
  pkgs,
  ...
}:
{
  services.postgresql = {
    enable = true;
    settings.port = 5432;
    package = pkgs.postgresql_17;
    enableTCPIP = true;
    ensureDatabases = [
      "hedgedoc"
      "atticd"
    ];
    ensureUsers = [
      {
        name = "atticd";
        ensureDBOwnership = true;
      }
    ];
  };
  services.postgresqlBackup = {
    enable = true;
    startAt = "hourly";
  };
}
