{
  config,
  pkgs,
  lib,
  ...
}:
{
  virtualisation.oci-containers.containers = {
    immich-ml =
      let
        modelCache = "/opt/immich-ml";
      in
      {
        image = "ghcr.io/immich-app/immich-machine-learning:release";
        autoStart = true;
        pull = "newer";
        ports = [ "3003:3003" ];
        environment = {
          REDIS_HOSTNAME = "immich-redis";
          DB_HOSTNAME = "immich-db";
        };
        volumes = [ "${modelCache}:/cache" ];
        networks = [ "immich-net" ];
      };
  };

  systemd.services.create-immich-net = rec {
    serviceConfig.Type = "oneshot";
    requiredBy = with config.virtualisation.oci-containers; [
      "${backend}-immich-ml.service"
    ];
    before = requiredBy;
    script = ''
      ${lib.getExe pkgs.podman} network exists immich-net || \
      ${lib.getExe pkgs.podman} network create immich-net
    '';
  };
}
