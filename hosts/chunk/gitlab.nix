{...}: {
  services.gitlab = {
    enable = true;
    https = true;
    host = "git.cything.io";
    user = "git"; # so that you can ssh with git@git.cything.io
    group = "git";
    port = 443; # this *not* the port gitlab will run on
    puma.workers = 0; # https://docs.gitlab.com/omnibus/settings/memory_constrained_envs.html#optimize-puma
    sidekiq.concurrency = 10;
    databaseUsername = "git"; # needs to be same as user
    initialRootEmail = "hi@cything.io";
    initialRootPasswordFile = "/run/secrets/gitlab/root";
    secrets = {
      secretFile = "/run/secrets/gitlab/secret";
      otpFile = "/run/secrets/gitlab/otp";
      jwsFile = "/run/secrets/gitlab/jws";
      dbFile = "/run/secrets/gitlab/db";
    };
  };
}
