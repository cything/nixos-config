{
  pkgs,
  config,
  ...
}:
let
  uploadLocation = "/mnt/photos/immich";
  thumbsLocation = "/opt/immich/thumbs";
  profileLocation = "/opt/immich/profile";
  dbDataLocation = "/opt/immich/postgres";
  modelCache = "/opt/immich-ml";
in
{
  virtualisation.oci-containers.containers = {
    immich-server = {
      image = "ghcr.io/immich-app/immich-server:release";
      autoStart = true;
      ports = [ "127.0.0.1:2283:2283" ];
      pull = "newer";
      volumes = [
        "${uploadLocation}:/usr/src/app/upload"
        "${thumbsLocation}:/usr/src/app/upload/thumbs"
        "${profileLocation}:/usr/src/app/upload/profile"
      ];
      environment = {
        REDIS_HOSTNAME = "immich-redis";
        DB_HOSTNAME = "immich-db";
      };
      networks = [ "immich-net" ];
      dependsOn = [
        "immich-db"
        "immich-redis"
      ];
    };

    immich-redis = {
      image = "redis:6.2-alpine";
      autoStart = true;
      pull = "newer";
      networks = [ "immich-net" ];
    };

    immich-db = {
      image = "tensorchord/pgvecto-rs:pg14-v0.2.0";
      autoStart = true;
      pull = "newer";
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

    immich-ml = {
      image = "ghcr.io/immich-app/immich-machine-learning:release";
      autoStart = true;
      pull = "newer";
      environment = {
        REDIS_HOSTNAME = "immich-redis";
        DB_HOSTNAME = "immich-db";
      };
      volumes = [ "${modelCache}:/cache" ];
      networks = [ "immich-net" ];
    };
  };

  systemd.services.create-immich-net = {
    serviceConfig.Type = "oneshot";
    wantedBy = with config.virtualisation.oci-containers; [
      "${backend}-immich.service"
      "${backend}-immich-db.service"
      "${backend}-immich-redis.service"
      "${backend}-immich-ml.service"
    ];
    script = ''
      ${pkgs.podman}/bin/podman network exists immich-net || \
      ${pkgs.podman}/bin/podman network create immich-net
    '';
  };
}
