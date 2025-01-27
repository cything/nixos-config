{
  pkgs,
  config,
  ...
}:
{
  virtualisation.oci-containers.containers.element = {
    image = "vectorim/element-web";
    autoStart = true;
    ports = [ "127.0.0.1:8089:8089" ];
    pull = "newer";
    networks = [ "element-net" ];
    environment = {
      ELEMENT_WEB_PORT = "8089";
    };
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

  services.caddy.virtualHosts."element.cy7.sh".extraConfig = ''
    import common
    reverse_proxy localhost:8089
  '';
}
