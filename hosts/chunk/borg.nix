{
  pkgs,
  config,
  ...
}: {
  services.borgbackup.jobs = {
    crashRsync = {
      paths = ["/root" "/home" "/var/backup" "/var/lib" "/var/log" "/opt" "/etc" "/vw-data"];
      exclude = ["**/.cache" "**/node_modules" "**/cache" "**/Cache" "/var/lib/docker" "/var/lib/containers/cache" "/var/lib/containers/overlay*"];
      repo = "de3911@de3911.rsync.net:borg/crash";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets."borg/rsyncnet".path}";
      };
      environment = {
        BORG_RSH = "ssh -i /home/yt/.ssh/id_ed25519";
        BORG_REMOTE_PATH = "borg1";
      };
      compression = "auto,zstd";
      startAt = "hourly";
      extraCreateArgs = ["--stats"];
      # warnings are often not that serious
      failOnWarnings = false;
      postHook = ''
        ${pkgs.curl}/bin/curl -u $(cat ${config.sops.secrets."services/ntfy".path}) -d "chunk: backup completed with exit code: $exitStatus
        $(journalctl -u borgbackup-job-crashRsync.service|tail -n 5)" \
        https://ntfy.cything.io/chunk
      '';
    };
  };
}
