{
  pkgs,
  config,
  ...
}: {
  systemd.services.immich-mount = {
    enable = true;
    description = "Mount the immich data remote";
    requires = ["network-online.target"];
    requiredBy = ["podman-immich-server.service"];
    serviceConfig = {
      Type = "notify";
      ExecStartPre = "/usr/bin/env mkdir -p /mnt/photos";
      ExecStart = "${pkgs.rclone}/bin/rclone mount --config /home/yt/.config/rclone/rclone.conf --cache-dir /var/cache/rclone --transfers=32 --dir-cache-time 72h --vfs-cache-mode writes --vfs-cache-max-size 2G photos: /mnt/photos ";
      ExecStop = "${pkgs.fuse}/bin/fusermount -u /mnt/photos";
      EnvironmentFile = config.sops.secrets."rclone/env".path;
    };
  };

  # systemd.services.nextcloud-mount = {
  #   enable = true;
  #   description = "Mount the nextcloud data remote";
  #   after = ["network-online.target"];
  #   requires = ["network-online.target"];
  #   wantedBy = ["default.target"];
  #   serviceConfig = {
  #     Type = "notify";
  #     ExecStartPre = "/usr/bin/env mkdir -p /mnt/nextcloud";
  #     ExecStart = "${pkgs.rclone}/bin/rclone mount --config /home/yt/.config/rclone/rclone.conf --uid 33 --gid 0 --allow-other --file-perms 0770 --dir-perms 0770 --transfers=32 rsyncnet:nextcloud /mnt/nextcloud";
  #     ExecStop = "/bin/fusermount -u /mnt/nextcloud";
  #     EnvironmentFile = config.sops.secrets."rclone/env".path;
  #   };
  # };

#   systemd.services.jellyfin-mount = {
#     enable = true;
#     description = "Mount the jellyfin data remote";
#     after = ["network-online.target"];
#     requires = ["network-online.target"];
#     requiredBy = ["jellyfin.service"];
#     serviceConfig = {
#       Type = "notify";
#       ExecStartPre = "/usr/bin/env mkdir -p /mnt/jellyfin";
#       ExecStart = "${pkgs.rclone}/bin/rclone mount --config /home/yt/.config/rclone/rclone.conf --allow-other --transfers=32 --dir-cache-time 72h --vfs-cache-mode writes --vfs-cache-max-size 2G jellyfin: /mnt/jellyfin";
#       ExecStop = "${pkgs.fuse}/bin/fusermount -u /mnt/jellyfin";
#       EnvironmentFile = config.sops.secrets."rclone/env".path;
#     };
#   };
  programs.fuse.userAllowOther = true;
}
