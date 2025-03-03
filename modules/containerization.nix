{
  config,
  lib,
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
      };
      oci-containers.backend = lib.mkIf cfg.usePodman "podman";
    };
  };
}
