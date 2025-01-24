{ config, ... }: {
  services.tailscale = {
    enable = false;
    authKeyFile = config.sops.secrets."tailscale/auth".path;
    openFirewall = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--exit-node=100.122.132.30"
    ];
  };
}
