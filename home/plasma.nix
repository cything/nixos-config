{ ... }:
{
  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.ide.breezedark.desktop";
      cursor = {
        theme = "Bibata-Modern-Classic";
        size = 32;
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
  };
}
