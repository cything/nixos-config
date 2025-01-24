{ config, ... }: {
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/auth".path;
    extraUpFlags = [ "--advertise-exit-node" ];
    useRoutingFeatures = "server";
    openFirewall = true;
  };
}
