{ config, ... }:
{
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/auth".path;
    openFirewall = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--exit-node=100.122.132.30"
      "--accept-dns=false"
    ];
  };
}
