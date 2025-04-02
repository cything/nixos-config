{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.caddy;
in
{
  options.my.caddy = {
    enable = lib.mkEnableOption "caddy reverse proxy";
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [
          # error message will tell you the correct version tag to use
          # (still need the @ to pass nix config check)
          "github.com/caddy-dns/cloudflare@v0.0.0-20250228175314-1fb64108d4de"
        ];
        hash = "sha256-YYpsf8HMONR1teMiSymo2y+HrKoxuJMKIea5/NEykGc=";
      };
      logFormat = lib.mkForce "level INFO";
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
      extraConfig = ''
        (common) {
          encode zstd gzip
          header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
          tls {
            dns cloudflare {$CLOUDFLARE_KEY}
            resolvers 1.1.1.1 8.8.8.8
          }
        }

        (authelia) {
          forward_auth localhost:9091 {
		        uri /api/authz/forward-auth
		        copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
	        }
        }
      '';
      environmentFile = config.sops.secrets."caddy/env".path;
      
      virtualHosts."keys.cy7.sh".extraConfig = ''
        import common
        respond / 200 {
          body "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfubDWr0kRm2o4DqaK6l1s4NCdTkljXZWKWCiF5nX+6
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPhUt9h5dCcrwOrZNKkStCX5OxumPzEwYXSU/0DgtWgP
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyn2+OoRN4nExti+vFQ1NHEZip0slAoCH9C5/FzvgZD"
        }
      '';
    };
  };
}
