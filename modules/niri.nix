{ pkgs, config, lib, ... }:
let
  cfg = config.my.niri;
in
{
  options.my.niri = {
    enable = lib.mkEnableOption "niri";
    package = lib.mkPackageOption pkgs "niri" { };
  };

  config = lib.mkIf cfg.enable {
    programs.niri.package = cfg.package;
    programs.niri.enable = true;
  };
}
