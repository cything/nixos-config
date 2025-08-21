{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.sway;
in
{
  options.my.sway = {
    enable = lib.mkEnableOption "sway";
  };

  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        rofi-wayland
        cliphist
        rofimoji
        grim
        slurp
        swaylock
        swayidle
        brightnessctl
        waybar
        wl-clipboard
        fuzzel
        kdePackages.dolphin
      ];
    };

    services.displayManager = {
      enable = true;
      autoLogin.user = "yt";
      defaultSession = "sway";
      sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;
      };
    };
  };
}
