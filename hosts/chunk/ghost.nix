{...}: {
  virtualisation.oci-containers.containers.ghost = {
    imgage = "ghost:5-alpine";
    autoStart = true;
    ports = ["127.0.0.1:8084:2368"];
    pull = "always";
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
    networks = [
      "ghost-net"
    ];
  };

  virtualisation.oci-containers.containers.ghost-db = {
    image = "mysql:8.0";
    autoStart = true;
    environment = {
      MYSQL_ROOT_PASSWORD = "example";
    };
    volumes = [
      "/opt/ghost/db:/var/lib/mysql"
    ];
    networks = [
      "ghost-net"
    ];
  };
}
