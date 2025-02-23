{ ... }:
{
  services.conduwuit = {
    enable = true;
    settings.global = {
      port = [ 8448 ];
      server_name = "cything.io";
      allow_check_for_updates = true;
    };
  };

  services.caddy.virtualHosts."chat.cything.io".extraConfig = ''
    import common
    reverse_proxy localhost:8448
  '';

  services.caddy.virtualHosts."cything.io" = {
    serverAliases = [ "www.cything.io" ];
    extraConfig = ''
      import common

      header /.well-known/matrix/* Content-Type application/json
      header /.well-known/matrix/* Access-Control-Allow-Origin *
      header /.well-known/matrix/* Access-Control-Allow-Methods GET,POST,PUT,DELETE,OPTIONS,PATCH,HEAD
      header /.well-known/matrix/* Access-Control-Allow-Headers X-Requested-With,Content-Type,Authorization,Origin,Accept
      route {
        respond /.well-known/matrix/server {"m.server":"chat.cything.io:443"}
        respond /.well-known/matrix/client {"m.server":{"base_url":"https://chat.cything.io"},"m.homeserver":{"base_url":"https://chat.cything.io"},"org.matrix.msc3575.proxy":{"url":"https://chat.cything.io"}}
        redir https://cy7.sh/posts{uri} permanent
      }
    '';
  };
}
