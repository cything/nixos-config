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
    ];
  };
  services.postgresqlBackup = {
    enable = true;
    startAt = "hourly";
  };
}
