{ ... }:
{
  programs.plasma = {
    enable = true;
    overrideConfig = true;
    immutableByDefault = true;
    workspace = {
      lookAndFeel = "org.ide.breezedark.desktop";
      cursor = {
        theme = "Bibata-Modern-Classic";
        size = 23;
      };
    };

    fonts = {
      general = {
        family = "IBM Plex Mono";
        pointSize = 12;
      };
    };

    input.keyboard = {
      numlockOnStartup = "on";
      options = [ "ctrl:nocaps" ];
    };

    # Meta key is actually the Super key in KDE

    hotkeys.commands = {
      "launch-terminal" = {
        name = "launch terminal";
        key = "Meta+Return";
        command = "kitty";
      };
      "launch-browser" = {
        name = "launch browser";
        key = "Meta+B";
        command = "chromium";
      };
      "launch-fuzzel" = {
        name = "launch-fuzzel";
        key = "Meta+d";
        command = "fuzzel";
      };
    };

    shortcuts = {
      kwin = {
        "Switch Window Down" = "Meta+J";
        "Switch Window Left" = "Meta+H";
        "Switch Window Right" = "Meta+L";
        "Switch Window Up" = "Meta+K";
        "Window Quick Tile Down" = "Meta+Shift+J";
        "Window Quick Tile Left" = "Meta+Shift+H";
        "Window Quick Tile Right" = "Meta+Shift+L";
        "Window Quick Tile Up" = "Meta+Shift+K";
        "Window Close" = "Meta+Ctrl+Q";
        "Window Maximize" = "Meta+W";
        "Window Minimize" = "Meta+Shift+-";
        "Window Fullscreen" = "Meta+F";
        "Window Shrink Horizontal" = "Meta+-";
      };

      ksmserver = {
        "Lock Session" = [
          "Screensaver"
          "Meta+Ctrl+L"
        ];
      };
    };

    configFile = {
      # save RAM
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
    };

    # looks like KDE overrides services.logind settings
    powerdevil.AC = {
      whenLaptopLidClosed = "hibernate";
    };
    powerdevil.battery = {
      whenLaptopLidClosed = "hibernate";
    };
  };
}
