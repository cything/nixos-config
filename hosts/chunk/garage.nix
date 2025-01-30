{ config, pkgs, ... }:
{
  services.garage = {
    enable = true;
    package = pkgs.garage;
    settings = {
      data_dir = "/mnt/garage";
      s3_api = {
        s3_region = "earth";
        api_bind_addr = "[::]:3900";
        root_domain = ".s3.cy7.sh";
      };
      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.s3.cy7.sh";
        index = "index.html";
      };
      admin.api_bind_addr = "[::]:3903";
      rpc_bind_addr = "[::]:3901";
      replication_factor = 1;
      db_engine = "lmdb";
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
    "*.web.s3.cy7.sh".extraConfig = ''
      import common
      reverse_proxy localhost:3902
    '';
    "admin.s3.cy7.sh".extraConfig = ''
      import common
      reverse_proxy localhost:3903
    '';
  };
}
