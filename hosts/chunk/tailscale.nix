{ config, ... }:
{
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/auth".path;
    extraUpFlags = [
      "--advertise-exit-node"
      "--accept-dns=false"
    ];
    useRoutingFeatures = "server";
    openFirewall = true;
  };
}
