{
  config,
  ...
}:
{
  my.backup = {
    enable = true;
    jobName = "titanRsync";
    repo = "titan";
    passFile = config.sops.secrets."borg/rsyncnet".path;
    sshKeyFile = config.sops.secrets."rsyncnet/id_ed25519".path;
  };
}
