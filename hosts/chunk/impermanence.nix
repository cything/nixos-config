{...}: {
  environment.persistence."/persistent" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/log"
      "/opt"
      "/var/lib"

      "/root/.config/borg" # nonce
      # used a hack to disable cache
      # see https://borgbackup.readthedocs.io/en/stable/faq.html#the-borg-cache-eats-way-too-much-disk-space-what-can-i-do
      "/root/.cache/borg"
      "/root/.config/sops"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
