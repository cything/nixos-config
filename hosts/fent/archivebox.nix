{
  config,
  lib,
  pkgs,
  ...
}:
let
  dataDir = "/opt/archivebox";
  piholeAddr = "172.20.0.53";
in
{
  virtualisation.oci-containers.containers = {
    archivebox = {
      image = "docker.io/archivebox/archivebox:latest";
      autoStart = true;
      ports = [ "127.0.0.1:8000:8000" ];
      pull = "always";
      volumes = [
        "${dataDir}/data:/data"
      ];
      environment = {
        ALLOWED_HOSTS = "archive.fentanyl.now";
        CSRF_TRUSTED_ORIGINS = "https://archive.fentanyl.now";
        PUBLIC_INDEX = "True";
        PUBLIC_SNAPSHOTS = "True";
        PUBLIC_ADD_VIEW = "False";
        SEARCH_BACKEND_ENGINE = "sonic";
        SEARCH_BACKEND_HOST_NAME = "sonic";
        SEARCH_BACKEND_PASSWORD = "secret1234";
      };
      networks = [ "pihole-net" ];
      extraOptions = [ "--dns=${piholeAddr}" ];
      dependsOn = [
        "sonic"
        "pihole"
      ];
    };

    sonic = {
      image = "docker.io/archivebox/sonic:latest";
      pull = "always";
      environment = {
        SEARCH_BACKEND_PASSWORD = "secret1234";
      };
      volumes = [
        "${dataDir}/data/sonic:/var/lib/sonic/store"
      ];
      extraOptions = [
        "--expose=1491"
      ];
    };

    pihole = {
      image = "docker.io/pihole/pihole:latest";
      pull = "always";
      ports = [ "8090:80" ];
      environment = {
        FTLCONF_webserver_api_password = "secret1234";
        DNSMASQ_LISTENING = "all";
      };
      volumes = [
        "${dataDir}/etc/pihole:/etc/pihole"
        "${dataDir}/etc/dnsmasq:/etc/dnsmasq.d"
      ];
      networks = [ "pihole-net" ];
      extraOptions = [
        "--dns=127.0.0.1"
        "--dns=1.1.1.1"
        "--ip=${piholeAddr}"
      ];
    };
  };

  systemd.services.create-pihole-net =
    let
      containers = [
        "archivebox"
        "pihole"
      ];
      backend = config.virtualisation.oci-containers.backend;
    in
    {
      serviceConfig.Type = "oneshot";
      requiredBy = map (
        x: "${backend}-" + x + ".service"
      ) containers;
      script = ''
        ${lib.getExe pkgs."${backend}"} network inspect pihole-net || \
        ${lib.getExe pkgs."${backend}"} network create --subnet 172.20.0.0/16 pihole-net
      '';
    };

  services.caddy.virtualHosts."archive.fentanyl.now".extraConfig = ''
    import common
    reverse_proxy 127.0.0.1:8000
  '';
}
