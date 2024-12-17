{
  pkgs,
  config,
  ...
}: {
  virtualisation.oci-containers.containers.conduit = {
    image = "matrixconduit/matrix-conduit:latest";
    autoStart = true;
    ports = ["127.0.0.1:8448:8448"];
    pull = "newer";
    environment = {
      CONDUIT_SERVER_NAME = "cything.io";
      CONDUIT_DATABASE_PATH = "/var/lib/matrix-conduit/";
      CONDUIT_DATABASE_BACKEND = "rocksdb";
      CONDUIT_PORT = "8448";
      CONDUIT_MAX_REQUEST_SIZE = "20000000"; # in bytes ~20MB
      CONDUIT_ALLOW_REGISTRATION = "false";
      CONDUIT_ALLOW_FEDERATION = "true";
      CONDUIT_ALLOW_CHECK_FOR_UPDATES = "true";
      CONDUIT_TRUSTED_SERVERS = ''["matrix.org"]'';
      CONDUIT_ADDRESS = "0.0.0.0";
      CONDUIT_CONFIG = "";
    };
    volumes = [
      "/opt/conduit/db:/var/lib/matrix-conduit/"
    ];
    networks = ["conduit-net"];
  };

  systemd.services.create-conduit-net = {
    serviceConfig.Type = "oneshot";
    wantedBy = with config.virtualisation.oci-containers; [
      "${backend}-conduit.service"
    ];
    script = ''
      ${pkgs.podman}/bin/podman network exists conduit-net || \
      ${pkgs.podman}/bin/podman network create conduit-net
    '';
  };
}
