{
  pkgs,
  config,
  lib,
  ...
}:
let
  mkServiceConfig = remote: mount: {
    Type = "notify";
    TimeoutSec = "5min 20s";
    ExecStartPre = "/usr/bin/env mkdir -p ${mount}";
    ExecStart = ''
      ${lib.getExe pkgs.rclone} mount \
        --config ${config.sops.secrets."rclone/config".path} \
        --allow-other \
        --cache-dir /var/cache/rclone \
        --transfers 16 \
        --vfs-cache-mode writes \
        --vfs-cache-min-free-space 5G \
        --dir-cache-time 30d \
        --no-modtime \
        --vfs-fast-fingerprint \
        --vfs-read-chunk-size 128M \
        --vfs-read-chunk-streams 0 \
        --sftp-concurrency 64 \
        --sftp-chunk-size 255k \
        --buffer-size 0 \
        --write-back-cache \
        ${remote} ${mount}
    '';
    ExecStop = "${lib.getExe' pkgs.fuse "fusermount"} -zu ${mount}";
    Restart = "on-failure";
  };
in
{
  systemd.services.immich-mount = {
    enable = true;
    description = "Mount the immich data remote";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    requiredBy = [ "podman-immich-server.service" ];
    before = [ "podman-immich-server.service" ];
    serviceConfig = mkServiceConfig "photos:" "/mnt/photos";
  };

  systemd.services.garage-mount = {
    enable = true;
    description = "Mount the garage data remote";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    requiredBy = [ "garage.service" ];
    before = [ "garage.service" ];
    serviceConfig = mkServiceConfig "rsyncnet:garage" "/mnt/garage";
  };
}
