{
  pkgs,
  config,
  ...
}: {
  virtualisation.oci-containers.containers.ghost = {
    image = "ghost:5-alpine";
    autoStart = true;
    ports = ["127.0.0.1:8084:2368"];
    pull = "newer";
    environment = {
      database__client = "mysql";
      database__connection__host = "ghost-db";
      database__connection__user = "root";
      database__connection__password = "example";
      database__connection__databse = "ghost";
      url = "https://cything.io";
      NODE_ENV = "production";
    };
    volumes = [
      "/opt/ghost/data:/var/lib/ghost/content"
    ];
    networks = ["ghost-net"];
    dependsOn = ["ghost-db"];
  };

  virtualisation.oci-containers.containers.ghost-db = {
    image = "mysql:8.0";
    autoStart = true;
    pull = "newer";
    environment = {
      MYSQL_ROOT_PASSWORD = "example";
    };
    volumes = [
      "/opt/ghost/db:/var/lib/mysql"
    ];
    networks = ["ghost-net"];
  };

  systemd.services.create-ghost-net = {
    serviceConfig.Type = "oneshot";
    wantedBy = with config.virtualisation.oci-containers; [
      "${backend}-ghost.service"
      "${backend}-ghost-db.service"
    ];
    script = ''
      ${pkgs.podman}/bin/podman network exists ghost-net || \
      ${pkgs.podman}/bin/podman network create ghost-net
    '';
  };
}
