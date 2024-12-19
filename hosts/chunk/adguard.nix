{ ... }:
{
  services.adguardhome = {
    enable = true;
    host = "127.0.0.1";
    port = 8082;
    settings = {
      http.port = "8083";
      users = [
        {
          name = "cy";
          password = "$2y$10$BZy2zYJj5z4e8LZCq/GwuuhWUafL/MNFO.YcsAMmpDS.2krPxi7KC";
        }
      ];
      # do not listen eveywhere cause podman runs it's own DNS
      dns.bind_hosts = [
        "127.0.0.1"
        "::1"
        "31.59.129.225"
        "2a0f:85c1:840:2bfb::1"
      ];
    };
  };
}
