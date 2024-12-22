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
        color= "002b36 93a1a1";
      };
      mouse = {
        hide-when-typing = "yes";
      };
      # tokyonight: https://codeberg.org/dnkl/foot/src/branch/master/themes/tokyonight-night
      colors = {
        background = "002b36";
        foreground = "839496";
        regular0 =   "073642";
        regular1 =   "dc322f";
        regular2 =   "859900";
        regular3 =   "b58900";
        regular4 =   "268bd2";
        regular5 =   "d33682";
        regular6 =   "2aa198";
        regular7 =   "eee8d5";

        bright0 = "08404f";
        bright1 = "e35f5c";
        bright2 = "9fb700";
        bright3 = "d9a400";
        bright4 = "4ba1de";
        bright5 = "dc619d";
        bright6 = "32c1b6";
        bright7 = "ffffff";
      };

      key-bindings = {
        clipboard-copy = "Control+Shift+c XF86Copy";
        clipboard-paste = "Control+Shift+v XF86Paste";
        quit = "Control+q";
      };
    };
  };
}
