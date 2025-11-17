{
  pkgs,
  config,
  lib,
  ...
}:
let
  uploadLocation = "/mnt/photos/immich";
  # thumbsLocation = "/opt/immich/thumbs";
  profileLocation = "/opt/immich/profile";
  dbDataLocation = "/opt/immich/postgres";
  backupsLocation = "/opt/immich/backups";
in
{
  virtualisation.oci-containers.containers = {
    immich-server = {
      image = "ghcr.io/immich-app/immich-server:release";
      autoStart = true;
      ports = [ "127.0.0.1:2283:2283" ];
      pull = "always";
      volumes = [
        "${uploadLocation}:/usr/src/app/upload"
        # "${thumbsLocation}:/usr/src/app/upload/thumbs"
        "${profileLocation}:/usr/src/app/upload/profile"
        "${backupsLocation}:/usr/src/app/upload/backups"
      ];
      environment = {
        REDIS_HOSTNAME = "immich-redis";
        DB_HOSTNAME = "immich-db";
      };
      networks = [ "immich-net" ];
      dependsOn = [
        "immich-db"
        "immich-redis"
        "immich-ml"
      ];
    };

    immich-redis = {
      image = "redis:6.2-alpine";
      autoStart = true;
      pull = "always";
      networks = [ "immich-net" ];
    };

    immich-db = {
      image = "tensorchord/pgvecto-rs:pg14-v0.2.0";
      autoStart = true;
      pull = "always";
      environment = {
        POSTGRES_PASSWORD = "postgres";
        POSTGRES_USER = "postgres";
        POSTGRES_DB = "immich";
        POSTGRES_INITDB_ARGS = "--data-checksums";
      };
      volumes = [ "${dbDataLocation}:/var/lib/postgresql/data" ];
      cmd = [
        "postgres"
        "-c"
        "shared_preload_libraries=vectors.so"
        "-c"
        ''search_path="$$user", public, vectors''
        "-c"
        "logging_collector=on"
        "-c"
        "max_wal_size=2GB"
        "-c"
        "shared_buffers=512MB"
        "-c"
        "wal_compression=on"
      ];
      networks = [ "immich-net" ];
    };

    immich-ml =
      let
        modelCache = "/opt/immich-ml";
      in
      {
        image = "ghcr.io/immich-app/immich-machine-learning:release";
        autoStart = true;
        pull = "always";
        ports = [ "3003:3003" ];
        environment = {
          REDIS_HOSTNAME = "immich-redis";
          DB_HOSTNAME = "immich-db";
        };
        volumes = [ "${modelCache}:/cache" ];
        networks = [ "immich-net" ];
        dependsOn = [
          "immich-db"
          "immich-redis"
        ];
      };
  };

  systemd.services.create-immich-net =
    let
      containers = [
        "immich-server"
        "immich-db"
        "immich-redis"
        "immich-ml"
      ];
      backend = config.virtualisation.oci-containers.backend;
    in
    {
      serviceConfig.Type = "oneshot";
      requiredBy = map (
        x: "${backend}-" + x + ".service"
      ) containers;
      script = ''
        ${lib.getExe pkgs."${backend}"} network inspect immich-net || \
        ${lib.getExe pkgs."${backend}"} network create immich-net
      '';
    };

  services.caddy.virtualHosts."photos.cy7.sh".extraConfig = ''
    import common
    reverse_proxy localhost:2283
  '';
}
