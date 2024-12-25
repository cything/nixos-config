{ ... }:
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "RobotoMono Nerd Font:size=8";
        dpi-aware = "yes";
      };
      bell = {
        urgent = "no";
        notify = "no";
        visual = "no";
      };
      cursor = {
        style = "beam";
        blink = "yes";
        blink-rate = 500;
        beam-thickness = 1.5;
      };
      mouse = {
        hide-when-typing = "yes";
      };
      # rose pine: https://codeberg.org/dnkl/foot/src/branch/master/themes/rose-pine
      colors = {
        # Nightfox colors for Xresources
        # Style: nightfox
        # Upstream: https://github.com/edeneast/nightfox.nvim/raw/main/extra/nightfox/nightfox.Xresources
        background = "192330";
        foreground = "cdcecf";
        regular0 =  "393b44";
        regular1 =  "c94f6d";
        regular2 =  "81b29a";
        regular3 =  "dbc074";
        regular4 =  "719cd6";
        regular5 =  "9d79d6";
        regular6 =  "63cdcf";
        regular7 =  "dfdfe0";
        bright0 =  "575860";
        bright1 =  "d16983";
        bright2 = "8ebaa4";
        bright3 = "e0c989";
        bright4 = "86abdc";
        bright5 = "baa1e2";
        bright6 = "7ad5d6";
        bright7 = "e4e4e5";
      };

      key-bindings = {
        clipboard-copy = "Control+Shift+c XF86Copy";
        clipboard-paste = "Control+Shift+v XF86Paste";
        quit = "Control+q";
      };
    };
  };
}
