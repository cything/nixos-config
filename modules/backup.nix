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
    "/var/lib/libvirt/images"
    "**/.rustup"
    "**/.cargo"
    "**/.docker"
    "**/borg"
  ];
in
{
  options.my.backup =
    let
      inherit (lib) mkOption types;
    in
    {
      enable = lib.mkEnableOption "backup";
      paths = mkOption {
        type = types.listOf lib.types.str;
        default = [ ];
        description = "Paths to backup. Appended to the list of defaultPaths";
      };
      exclude = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Paths to exclude. Appended to the list of defaultExclude";
      };
      repo = mkOption {
        type = types.nonEmptyStr;
        default = "${config.networking.hostName}-backup";
      };
      remote = mkOption {
        type = types.nonEmptyStr;
        default = "zh5061.rsync.net";
      };
      remoteUser = mkOption {
        type = types.nonEmptyStr;
        default = "zh5061";
      };
      startAt = mkOption {
        type = types.str;
        default = "daily";
        description = "see systemd.timer(5)";
      };
      passFile = mkOption {
        type = types.str;
        description = "Path to the file containing the encryption passphrase";
      };
      sshKeyFile = mkOption {
        type = types.str;
        description = "Path to the file containing the SSH identity key";
      };
      host = mkOption {
        type = types.nonEmptyStr;
        default = config.networking.hostName;
      };
    };

  config = lib.mkIf cfg.enable {

    services.restic.backups."${config.networking.hostName}-${cfg.remote}" = {
      timerConfig = {
        OnCalendar = cfg.startAt;
        Persistent = true;
      };
      paths = defaultPaths ++ cfg.paths;
      exclude = defaultExclude ++ cfg.exclude;
      repository = "sftp:${cfg.remoteUser}@${cfg.remote}:restic-repos/${cfg.repo}";
      passwordFile = cfg.passFile;

      extraOptions =
        let
          knownHost = (
            pkgs.writeText "rsyncnet-keys" ''
              zh5061.rsync.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJtclizeBy1Uo3D86HpgD3LONGVH0CJ0NT+YfZlldAJd
            ''
          );
        in
        [
          "sftp.command='ssh ${cfg.remoteUser}@${cfg.remote} -i ${cfg.sshKeyFile} -o UserKnownHostsFile=${knownHost} -s sftp'"
        ];

      extraBackupArgs = [
        "--compression=max"
        "--pack-size=128"
        "--read-concurrency=8"
        "--host=${cfg.host}"
      ];
    };
  };
}
