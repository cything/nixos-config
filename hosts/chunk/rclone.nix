{pkgs, ...}: {
  systemd.services.immich-mount = {
    enable = true;
    description = "Mount the immich data remote";
    after = ["network-online.target"];
    requires = ["network-online.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      Type = "notify";
      ExecStartPre = "/usr/bin/env mkdir -p /mnt/photos";
      ExecStart = "${pkgs.rclone}/bin/rclone mount --config /home/yt/.config/rclone/rclone.conf --transfers=32 --dir-cache-time 720h --poll-interval 0 --vfs-cache-mode writes photos: /mnt/photos ";
      ExecStop = "/bin/fusermount -u /mnt/photos";
      EnvironmentFile = "/run/secrets/rclone";
    };
  };

  systemd.services.nextcloud-mount = {
    enable = true;
    description = "Mount the nextcloud data remote";
    after = ["network-online.target"];
    requires = ["network-online.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.rclone}/bin/rclone mount --config /home/yt/.config/rclone/rclone.conf --uid 33 --gid 0 --allow-other --file-perms 0770 --dir-perms 0770 --transfers=32 rsyncnet:nextcloud /mnt/nextcloud";
      ExecStop = "/bin/fusermount -u /mnt/nextcloud";
      EnvironmentFile = "/run/secrets/rclone";
    };
  };
  programs.fuse.userAllowOther = true;
}
