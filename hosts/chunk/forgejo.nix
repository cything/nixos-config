{ pkgs, ... }:
{
  services.forgejo = {
    enable = true;
    package = pkgs.forgejo; # uses forgejo-lts by default
    user = "git";
    group = "git";
    settings = {
      server = {
        ROOT_URL = "https://git.cy7.sh";
        HTTP_PORT = 3000;
        HTTP_ADDR = "127.0.0.1";
        DOMAIN = "git.cy7.sh";
        LANDING_PAGE = "explore";
      };
      session.COOKIE_SECURE = true;
      service.DISABLE_REGISTRATION = true;
      ui = {
        AMBIGUOUS_UNICODE_DETECTION = false;
        DEFAULT_THEME = "forgejo-dark";
      };
      actions.ENABLED = false;
      repository.ENABLE_PUSH_CREATE_USER = true;
      indexer.REPO_INDEXER_ENABLED = true;
    };
    database = {
      type = "postgres";
      socket = "/run/postgresql";
      user = "git";
      name = "git";
    };
  };
}
