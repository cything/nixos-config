{...}:
{
  services.shiori = {
    enable = true;
    address = "127.0.0.1";
    port = 8091;
    databaseUrl = "postgres:///shiori?host=/run/postgresql";
  };

  services.caddy.virtualHosts."link.cy7.sh".extraConfig = ''
    import common
    reverse_proxy localhost:8091
  '';
}
