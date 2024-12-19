{
  pkgs,
  lib,
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
    authentication = lib.mkForce ''
      local all all trust
      host  all all 127.0.0.1/32 trust
      host  all all ::1/128 trust
      host  all all 172.18.0.0/16 trust
    '';
  };
  services.postgresqlBackup.enable = true;
}
