{
  config,
  lib,
  ...
}:
let
  cfg = config.my.kde;
in
{
  options.my.kde = {
    enable = lib.mkEnableOption "KDE Plasma DE";
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6 = {
      enable = true;
    };

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      autoNumlock = true;
    };
    services.displayManager.defaultSession = "plasma";
    services.displayManager = {

    };
  };
}
