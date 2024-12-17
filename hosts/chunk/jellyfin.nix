{...}: {
  services.jellyfin = {
    enable = true;
    dataDir = "/mnt/jellyfin";
    configDir = "/var/lib/jellyfin/config";
  };
}
