{ ... }:
{
  my.vaultwarden.enable = true;

  services.caddy.virtualHosts."pass.cy7.sh".extraConfig = ''
    import common
    reverse_proxy localhost:8081
  '';
}
