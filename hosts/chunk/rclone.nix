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
        --transfers 32 \
        --vfs-cache-mode full \
        --vfs-cache-min-free-space 5G \
        --dir-cache-time 30d \
        --no-checksum \
        --no-modtime \
        --vfs-fast-fingerprint \
        --vfs-read-chunk-size 16M \
        --vfs-read-chunk-streams 16 \
        --sftp-concurrency 64 \
        --sftp-chunk-size 255k \
        --buffer-size 0 \
        ${remote} ${mount}
    '';
    ExecStop = "${lib.getExe' pkgs.fuse "fusermount"} -zu ${mount}";
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
