{
  config,
  ...
}:
{
  my.backup = {
    enable = true;
    paths = [
      "/var/backup"
    ];
    repo = "chunk";
    passFile = config.sops.secrets."restic/zh5061".path;
    sshKeyFile = config.sops.secrets."rsyncnet/id_ed25519".path;
  };
}
