{ ... }:
{
  services.deluge = {
    enable = true;
    web = {
      enable = true;
      port = 8112;
    };
  };

  services.caddy.virtualHosts."t.cy7.sh".extraConfig = ''
    import common
    reverse_proxy localhost:8112
  '';
}
