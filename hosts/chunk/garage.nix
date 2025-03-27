{ config, pkgs, ... }:
{
  services.garage = {
    enable = true;
    package = pkgs.garage;
    settings = {
      data_dir = "/mnt/garage";
      s3_api = {
        s3_region = "us-east-1";
        api_bind_addr = "[::]:3900";
        root_domain = "s3.cy7.sh";
      };
      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.cy7.sh";
        add_host_to_metrics = true;
      };
      admin.api_bind_addr = "[::]:3903";
      rpc_bind_addr = "[::]:3901";
      replication_factor = 1;
      db_engine = "lmdb";
      disable_scrub = true;
      block_size = "128M";
      compression_level = "none";
    };
    environmentFile = config.sops.secrets."garage/env".path;
  };

  services.caddy.virtualHosts = {
    "s3.cy7.sh" = {
      serverAliases = [ "*.s3.cy7.sh" ];
      extraConfig = ''
        import common
        reverse_proxy localhost:3900
      '';
    };
    "admin.s3.cy7.sh".extraConfig = ''
      import common
      reverse_proxy localhost:3903
    '';
    "*.web.cy7.sh" = {
      serverAliases = [ "nixcache.cy7.sh" ];
      extraConfig = ''
        import common
        reverse_proxy localhost:3902
      '';
    };
  };
}
