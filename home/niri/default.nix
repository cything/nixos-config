{ config, pkgs, lib, ... }:
let
  wallpaper = "${./nixos-c-book.png}";
  terminal = "foot";
  menu = "fuzzel";
  browser = "librewolf";
  file-manager = "thunar";
in
{
  programs.niri.settings =
  {
    prefer-no-csd = true;
    input.keyboard.xkb.options = "ctrl:nocaps";
    spawn-at-startup = [
      { command = [ "waybar" ]; }
      { command = [ "${lib.getExe pkgs.swaybg}" "-m" "fill" "-i" wallpaper ]; }
    ];
  };

  programs.niri.settings.binds =
    with config.lib.niri.actions;
    let
      sh = spawn "sh" "-c";
    in
    {
      "Mod+Return".action = spawn terminal;
      "Mod+D".action = spawn menu;

      "Mod+Shift+E".action = quit;
      "Mod+Equal".action = set-column-width "+10%";
      "Mod+Minus".action = set-column-width "-10%";
      "Mod+Shift+Equal".action = set-window-height "+10%";
      "Mod+Shift+Minus".action = set-window-height "-10%";
      "Super+Alt+L".action = spawn "swaylock";
      "Mod+Ctrl+Q".action = close-window;
      "Mod+H".action = focus-column-left;
      "Mod+L".action = focus-column-right;
      "Mod+K".action = focus-window-up;
      "Mod+J".action = focus-window-down;
      "Mod+Shift+H".action = move-column-left;
      "Mod+Shift+L".action = move-column-right;
      "Mod+Shift+K".action = move-window-up;
      "Mod+Shift+J".action = move-window-down;
      "Mod+U".action = focus-workspace-up;
      "Mod+I".action = focus-workspace-down;
      "Mod+Shift+U".action = move-workspace-up;
      "Mod+Shift+I".action = move-workspace-down;
      "Mod+W".action = maximize-column;
      "Mod+C".action = center-column;
      "Mod+Shift+Space".action = toggle-window-floating;
      "Mod+Space".action = switch-focus-between-floating-and-tiling;
      "Print".action = screenshot;
      "Alt+Print".action = screenshot-window;
      "Ctrl+Print".action = screenshot-screen;
      "Mod+R".action = switch-preset-column-width;
      "Mod+Shift+R".action = switch-preset-window-height;
      "Mod+Ctrl+R".action = reset-window-height;
      "Mod+F".action = fullscreen-window;

      "XF86AudioRaiseVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
      "XF86AudioLowerVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
      "XF86AudioMute".action = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      "XF86MonBrightnessUp".action = sh "brightnessctl set 10%+";
      "XF86MonBrightnessDown".action = sh "brightnessctl set 10%-";

      "Mod+1".action = focus-workspace 1;
      "Mod+2".action = focus-workspace 2;
      "Mod+3".action = focus-workspace 3;
      "Mod+4".action = focus-workspace 4;
      "Mod+5".action = focus-workspace 5;

      "Mod+Alt+B".action = spawn browser;
      "Mod+Alt+A".action = spawn "anki";
      "Mod+Alt+F".action = spawn file-manager;
      "Mod+Alt+E".action = spawn "evolution";
      "Mod+P".action = spawn "bitwarden";
    };
}
