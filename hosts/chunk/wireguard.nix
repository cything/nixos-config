{
  pkgs,
  config,
  ...
}:
{
  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "ens18";
    internalInterfaces = [ "wg0" ];
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [
      "10.0.0.1/24"
      "fdc9:281f:04d7:9ee9::1/64"
    ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets."wireguard/private".path;
    postUp = ''
      ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -o wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -A FORWARD -o wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
    '';
    preDown = ''
      ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ens18 -j MASQUERADE
      ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -D FORWARD -o wg0 -j ACCEPT
      ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -o ens18 -j MASQUERADE
    '';
    peers = [
      {
        publicKey = "qUhWoTPVC7jJdDEJLYY92OeiwPkaf8I5pv5kkMcSW3g=";
        allowedIPs = [
          "10.0.0.2/32"
          "fdc9:281f:04d7:9ee9::2/128"
        ];
        presharedKeyFile = config.sops.secrets."wireguard/psk-yt".path;
      }
      {
        publicKey = "JIGi60wzLw717Cim1dSFoLCdJz5rePa5AIFfuisJI0k=";
        allowedIPs = [
          "10.0.0.3/32"
          "fdc9:281f:04d7:9ee9::3/128"
        ];
        presharedKeyFile = config.sops.secrets."wireguard/psk-phone".path;
      }
    ];
  };
}
