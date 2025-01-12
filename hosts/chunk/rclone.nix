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
      } --cache-dir /var/cache/rclone --transfers=32 --checkers=32 --dir-cache-time 72h --vfs-cache-mode writes --vfs-cache-max-size 2G photos: /mnt/photos ";
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
      } --cache-dir /var/cache/rclone --transfers=32 --checkers=32 --vfs-cache-mode writes --vfs-cache-max-size 15G --allow-other rsyncnet:attic /mnt/attic ";
      ExecStop = "${lib.getExe' pkgs.fuse "fusermount"} -u /mnt/attic";
    };
  };

  systemd.services.garage-mount = {
    enable = true;
    description = "Mount the garage data remote";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    requiredBy = [ "garage.service" ];
    before = [ "garage.service" ];
    serviceConfig = {
      Type = "notify";
      ExecStartPre = "/usr/bin/env mkdir -p /mnt/garage";
      ExecStart = "${lib.getExe pkgs.rclone} mount --config ${
        config.sops.secrets."rclone/config".path
      } --cache-dir /var/cache/rclone --transfers=32 --checkers=32 --vfs-cache-mode writes --vfs-cache-max-size 5G --allow-other rsyncnet:garage /mnt/garage ";
      ExecStop = "${lib.getExe' pkgs.fuse "fusermount"} -u /mnt/garage";
    };
  };

  systemd.services.minio-mount = {
    enable = true;
    description = "Mount the minio data remote";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    requiredBy = [ "minio.service" ];
    before = [ "minio.service" ];
    serviceConfig = {
      Type = "notify";
      ExecStartPre = "/usr/bin/env mkdir -p /mnt/minio";
      ExecStart = "${lib.getExe pkgs.rclone} mount --config ${
        config.sops.secrets."rclone/config".path
      } --cache-dir /var/cache/rclone --transfers=32 --checkers=32 --vfs-cache-mode writes --vfs-cache-max-size 5G --allow-other rsyncnet:minio /mnt/minio ";
      ExecStop = "${lib.getExe' pkgs.fuse "fusermount"} -u /mnt/minio";
    };
  };

  programs.fuse.userAllowOther = true;
}
