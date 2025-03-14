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
      admin.api_bind_addr = "[::]:3903";
      rpc_bind_addr = "[::]:3901";
      replication_factor = 1;
      db_engine = "lmdb";
      disable_scrub = true;
      block_size = "10M";
      compression_level = 3;
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
  };
}
