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
      ExecStart = ''
        ${lib.getExe pkgs.rclone} mount \
          --config ${config.sops.secrets."rclone/config".path} \
          --allow-other \
          --cache-dir /var/cache/rclone \
          --transfers=32 --checkers=32 \
          --vfs-cache-mode writes \
          --vfs-cache-max-size 5G \
          --dir-cache-time 30d \
          rsyncnet:garage /mnt/garage
      '';
      ExecStop = "${lib.getExe' pkgs.fuse "fusermount"} -u /mnt/garage";
    };
  };
}
