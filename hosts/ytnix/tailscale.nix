{ config, ... }:
{
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/auth".path;
    openFirewall = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--reset"
      "--exit-node=chunk"
      "--accept-dns=false"
      "--operator=yt"
      "--exit-node-allow-lan-access"
    ];
    extraDaemonFlags = [
      "--no-logs-no-support"
    ];
  };
}
