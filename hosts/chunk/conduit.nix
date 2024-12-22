{
  pkgs,
  config,
  ...
}:
{
  virtualisation.oci-containers.containers.conduit = {
    image = "ghcr.io/girlbossceo/conduwuit:main";
    autoStart = true;
    ports = [ "127.0.0.1:8448:8448" ];
    pull = "newer";
    environment = {
      CONDUWUIT_SERVER_NAME = "cything.io";
      CONDUWUIT_DATABASE_PATH = "/var/lib/conduwuit";
      CONDUWUIT_PORT = "8448";
      CONDUWUIT_MAX_REQUEST_SIZE = "20000000"; # in bytes ~20MB
      CONDUWUIT_ALLOW_REGISTRATION = "false";
      CONDUWUIT_ALLOW_FEDERATION = "true";
      CONDUWUIT_ALLOW_CHECK_FOR_UPDATES = "true";
      CONDUWUIT_TRUSTED_SERVERS = ''["matrix.org"]'';
      CONDUWUIT_ADDRESS = "0.0.0.0";
      # CONDUIT_CONFIG = "";
    };
    volumes = [
      "/opt/conduit/db:/var/lib/conduwuit/"
    ];
    networks = [ "conduit-net" ];
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
