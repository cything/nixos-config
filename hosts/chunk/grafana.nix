{ config, ... }:
{
  services.grafana = {
    enable = true;
    settings.server = {
      http_addr = "127.0.0.1";
      http_port = 8088;
      enforce_domain = true;
      enable_gzip = true;
      domain = "grafana.cy7.sh";
    };
    settings.analytics.reporting_enabled = false;
  };

  services.prometheus = {
    enable = true;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
      };
    };
    scrapeConfigs = [
      {
        job_name = "chrysalis";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
      {
        job_name = "garage";
        static_configs = [
          {
            targets = [ "127.0.0.1:3903" ];
          }
        ];
      }
    ];
  };

  services.caddy.virtualHosts."grafana.cy7.sh".extraConfig = ''
    import common
    import authelia
    reverse_proxy localhost:8088
  '';
}
