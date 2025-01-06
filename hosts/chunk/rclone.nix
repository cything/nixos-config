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

  systemd.services.attic-mount = {
    enable = true;
    description = "Mount the attic data remote";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    requiredBy = [ "atticd.service" ];
    before = [ "atticd.service" ];
    serviceConfig = {
      Type = "notify";
      ExecStartPre = "/usr/bin/env mkdir -p /mnt/attic";
      ExecStart = "${lib.getExe pkgs.rclone} mount --config ${
        config.sops.secrets."rclone/config".path
      } --cache-dir /var/cache/rclone --transfers=32 --allow-other --cache-dir /var/cache/rclone --dir-cache-time 72h --vfs-cache-mode writes --vfs-cache-max-size 2G rsyncnet:attic /mnt/attic ";
      ExecStop = "${lib.getExe' pkgs.fuse "fusermount"} -u /mnt/attic";
    };
  };
  programs.fuse.userAllowOther = true;
}
