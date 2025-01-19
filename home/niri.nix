{ config, ...}:
{
  programs.niri.settings = {
    prefer-no-csd = true;
  };
  
  programs.niri.settings.binds = with config.lib.niri.actions; {
    "Mod+Return".action = spawn "foot";
    "Mod+D".action = spawn "fuzzel";
    
    "Mod+Shift+E".action = quit;
    "Mod+Equal".action = set-column-width "+10%";
    "Mod+Minus".action = set-column-width "-10%";
    "Mod+Shift+Equal".action = set-window-height "+10%";
    "Mod+Shift+Minus".action = set-window-height "-10%";
    "Mod+1".action = focus-workspace 1;
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
  };
}
