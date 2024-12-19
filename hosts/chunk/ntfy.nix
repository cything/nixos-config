{ ... }:
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      listen-http = "127.0.0.1:8083";
      base-url = "https://ntfy.cything.io";
      upstream-base-url = "https://ntfy.sh";
      auth-default-access = "deny-all";
      behind-proxy = true;
    };
  };
}
