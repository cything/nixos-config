{config, ...}: {
  services.minio = {
    enable = true;
    rootCredentialsFile = config.sops.secrets."minio/env".path;
    region = "universe";
    dataDir = ["/mnt/minio"];
  };
}
