{
  config,
  lib,
  ...
}:
let
  cfg = config.my.vault;
in
{
  options.my.vault = {
    enable = lib.mkEnableOption "hashicorp vault";
  };

  config = lib.mkIf cfg.enable {
    services.vault = {

    };
  };
}