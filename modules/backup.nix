{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.backup;
  hostname = config.networking.hostName;
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
  imports = [
    {
      disabledModules = [ "services/backup/borgbackup.nix" ];
    }
    (inputs.nixpkgs-borg + "/nixos/modules/services/backup/borgbackup.nix")
  ];

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
      description = "Borg repository to backup to. This is appended to `de3911@de3911.rsync.net:borg/`.";
    };
    startAt = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
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
        de3911.rsync.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObQN4P/deJ/k4P4kXh6a9K4Q89qdyywYetp9h3nwfPo
      '')
    ]; # needs to be a list

    services.borgbackup.jobs.${cfg.jobName} = {
      inherit (cfg) startAt;

      # systemd.timer(5)
      persistentTimer = true;
      paths = defaultPaths ++ cfg.paths;
      exclude = defaultExclude ++ cfg.exclude;
      repo = "de3911@de3911.rsync.net:borg/" + cfg.repo;
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${cfg.passFile}";
      };
      environment = {
        BORG_RSH = "ssh -i ${cfg.sshKeyFile}";
        BORG_REMOTE_PATH = "borg1";
        BORG_EXIT_CODES = "modern";
      };
      compression = "auto,zstd,8";
      extraCreateArgs = [
        "--stats"
        "-x"
      ];
      # warnings are often not that serious
      failOnWarnings = false;
      postHook = ''
        invocationId=$(systemctl show -p InvocationID --value borgbackup-job-${cfg.jobName}.service)
        title="${hostname}: backup completed with exit code: $exitStatus"
        msg=$(journalctl -o cat _SYSTEMD_INVOCATION_ID=$invocationId)

        if [ "$exitStatus" -eq 0 ]; then
          tag="v"
        else
          tag="rotating_light"
        fi

        ${pkgs.curl}/bin/curl -sL -u $(cat ${config.sops.secrets."services/ntfy".path}) \
        -H "Title: $title" \
        -H "Tags: $tag" \
        -d "$msg" \
        https://ntfy.cything.io/backups > /dev/null
      '';

      prune.keep = {
        within = "2d";
        daily = 365;
      };
      extraPruneArgs = [ "--stats" ];
    };
  };
}
