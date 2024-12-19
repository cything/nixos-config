{ ... }:
{
  services.tor = {
    enable = true;
    openFirewall = true;
    relay = {
      enable = true;
      role = "relay";
    };
    settings = {
      ORPort = 9001;
      Nickname = "chunk";
      MaxAdvertisedBandwidth = "20MBytes";
    };
  };
}
