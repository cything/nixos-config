{
  pkgs,
  config,
  ...
}:
{
  virtualisation.oci-containers.containers.element = {
    image = "vectorim/element-web";
    autoStart = true;
    ports = [ "127.0.0.1:8089:80" ];
    pull = "newer";
    networks = [ "element-net" ];
  };

  systemd.services.create-element-net = {
    serviceConfig.Type = "oneshot";
    wantedBy = with config.virtualisation.oci-containers; [
      "${backend}-element.service"
    ];
    script = ''
      ${pkgs.podman}/bin/podman network exists element-net || \
      ${pkgs.podman}/bin/podman network create element-net
    '';
  };
}
