{
  pkgs,
  config,
  lib,
  ...
}:
{
  systemd.services.immich-mount = {
    enable = true;
    description = "Mount the immich data remote";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    requiredBy = [ "podman-immich-server.service" ];
    before = [ "podman-immich-server.service" ];
    serviceConfig = {
      Type = "notify";
      ExecStartPre = "/usr/bin/env mkdir -p /mnt/photos";
      ExecStart = "${lib.getExe pkgs.rclone} mount --config ${
        config.sops.secrets."rclone/config".path
      } --cache-dir /var/cache/rclone --transfers=32 --dir-cache-time 72h --vfs-cache-mode writes --vfs-cache-max-size 2G photos: /mnt/photos ";
      ExecStop = "${lib.getExe' pkgs.fuse "fusermount"} -u /mnt/photos";
    };
  };

  systemd.services.harmonia-mount = {
    enable = true;
    description = "Mount the harmonia data remote";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    requiredBy = [ "harmonia.service" ];
    before = [ "harmonia.service" ];
    serviceConfig = {
      Type = "notify";
      ExecStartPre = "/usr/bin/env mkdir -p /mnt/harmonia";
      ExecStart = "${lib.getExe pkgs.rclone} mount --config ${
        config.sops.secrets."rclone/config".path
      } --cache-dir /var/cache/rclone --transfers=32 --allow-other rsyncnet:harmonia /mnt/harmonia ";
      ExecStop = "${lib.getExe' pkgs.fuse "fusermount"} -u /mnt/harmonia";
    };
  };
  programs.fuse.userAllowOther = true;
}
