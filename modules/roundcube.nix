{ config, lib, pkgs, ... }:
let
  cfg = config.my.roundcube;
  fpm = config.services.phpfpm.pools.roundcube;
  roundcube = config.services.roundcube;
in
{
  options.my.roundcube = {
    enable = lib.mkEnableOption "roundcube webmail";
  };

  config = lib.mkIf cfg.enable {
    services.roundcube = {
      enable = true;
      configureNginx = false;
      package = pkgs.roundcube.withPlugins (p: with p; [
        persistent_login
        contextmenu
        custom_from
        thunderbird_labels
      ]);
      plugins = [
        "persistent_login"
        "contextmenu"
        "custom_from"
        "thunderbird_labels"
      ];
      dicts = with pkgs.aspellDicts; [ en ];
      extraConfig = ''
        $config['imap_host'] = "ssl://imap.migadu.com:993";
        $config['smtp_host'] = "ssl://smtp.migadu.com:465";
        $config['smtp_user'] = "%u";
        $config['smtp_pass'] = "%p";
      '';
    };

    services.phpfpm.pools.roundcube.settings = lib.mapAttrs (name: lib.mkForce) {
      "listen.owner" = "caddy";
      "listen.group" = "caddy";
    };

    services.caddy.virtualHosts."mail.cy7.sh".extraConfig = ''
      import common
      root ${roundcube.package}
      php_fastcgi unix/${fpm.socket}
      file_server
    '';
  };
}
