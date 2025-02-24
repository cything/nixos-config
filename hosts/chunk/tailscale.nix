{ config, ... }:
{
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/auth".path;
    extraUpFlags = [
      "--advertise-exit-node"
      "--accept-dns=false"
    ];
    extraDaemonFlags = [
      "--no-logs-no-support"
    ];
    useRoutingFeatures = "server";
    openFirewall = true;
  };
}
