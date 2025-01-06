{
  config,
  ...
}:
{
  my.backup = {
    enable = false;
    jobName = "titanRsync";
    repo = "titan";
    passFile = config.sops.secrets."borg/rsyncnet".path;
    sshKeyFile = config.sops.secrets."rsyncnet/id_ed25519".path;
  };
}
