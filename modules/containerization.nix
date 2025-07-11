{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.containerization;
in
{
  options.my.containerization = {
    enable = lib.mkEnableOption "containerization";
    usePodman = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "whether to use podman instead of docker";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;
      podman = lib.mkIf cfg.usePodman {
        enable = true;
        # create 'docker' alias for podman, to use as
        # drop-in replacement
        dockerCompat = true;
        defaultNetwork.settings = {
          dns_enabled = true;
          ipv6_enabled = true;
        };
        # answer on /var/run/docker.sock
        dockerSocket.enable = true;
        autoPrune = {
          enable = true;
          dates = "daily";
        };
        extraPackages = with pkgs; [ docker-compose ];
      };
      docker.enable = lib.mkIf (!cfg.usePodman) true;
      oci-containers.backend = lib.mkIf (!cfg.usePodman) "docker";
    };
  };
}
