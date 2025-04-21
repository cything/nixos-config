{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.backup;
  defaultPaths = [
    "/root"
    "/home"
    "/var/lib"
    "/opt"
    "/etc"
  ];
  defaultExclude = [
    "**/.cache"
    "**/node_modules"
    "**/cache"
    "**/Cache"
    "/var/lib/docker"
    "/var/lib/containers" # podman
    "/var/lib/systemd"
    "/var/lib/libvirt"
    "**/.rustup"
    "**/.cargo"
    "**/.docker"
    "**/borg"
  ];
in
{
  options.my.backup = {
    enable = lib.mkEnableOption "backup";
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Paths to backup. Appended to the list of defaultPaths";
    };
    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Paths to exclude. Appended to the list of defaultExclude";
    };
    repo = lib.mkOption {
      type = lib.types.str;
      description = "Borg repository to backup to. This is appended to `zh5061@zh5061.rsync.net:borg/`.";
    };
    startAt = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "see systemd.timer(5)";
    };
    jobName = lib.mkOption {
      type = lib.types.str;
      description = "Name of the job to run as. Archives created are prefixed with hostName-jobName";
    };
    passFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to the file containing the encryption passphrase";
    };
    sshKeyFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to the file containing the SSH identity key";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh.knownHostsFiles = [
      (pkgs.writeText "rsyncnet-keys" ''
        zh5061.rsync.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJtclizeBy1Uo3D86HpgD3LONGVH0CJ0NT+YfZlldAJd
      '')
    ]; # needs to be a list

    services.borgbackup.jobs.${cfg.jobName} = {
      inherit (cfg) startAt;

      # systemd.timer(5)
      persistentTimer = true;
      paths = defaultPaths ++ cfg.paths;
      exclude = defaultExclude ++ cfg.exclude;
      repo = "zh5061@zh5061.rsync.net:borg/" + cfg.repo;
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${cfg.passFile}";
      };
      environment = {
        BORG_RSH = "ssh -i ${cfg.sshKeyFile}";
        BORG_REMOTE_PATH = "borg1";
        BORG_EXIT_CODES = "modern";
        BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
      };
      compression = "auto,zstd,8";
      extraCreateArgs = [
        "--stats"
        "-x"
      ];
      # warnings are often not that serious
      failOnWarnings = false;

      prune.keep = {
        daily = 7;
        weekly = 12;
        monthly = -1;
      };
      extraPruneArgs = [ "--stats" ];
    };
  };
}
