{
  config,
  ...
}:
{
  my.backup = {
    enable = true;
    jobName = "crashRsync";
    paths = [
      "/vw-data"
    ];
    exclude = [
      # podman stuff
      "/var/lib/containers"
    ];
    repo = "crash";
    passFile = config.sops.secrets."borg/rsyncnet".path;
    sshKeyFile = config.sops.secrets."rsyncnet/id_ed25519".path;
  };
}
