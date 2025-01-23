{ ... }:
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "IBM Plex Mono:size=8";
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
        color = "161821 c6c8d1";
      };
      mouse = {
        hide-when-typing = "yes";
      };
      colors = {
        foreground = "c6c8d1";
        background = "161821";
        regular0 = "1e2132";
        regular1 = "e27878";
        regular2 = "b4be82";
        regular3 = "e2a478";
        regular4 = "84a0c6";
        regular5 = "a093c7";
        regular6 = "89b8c2";
        regular7 = "c6c8d1";
        bright0 = "6b7089";
        bright1 = "e98989";
        bright2 = "c0ca8e";
        bright3 = "e9b189";
        bright4 = "91acd1";
        bright5 = "ada0d3";
        bright6 = "95c4ce";
        bright7 = "d2d4de";
        selection-foreground = "161821";
        selection-background = "c6c8d1";
      };

      key-bindings = {
        clipboard-copy = "Control+Shift+c XF86Copy";
        clipboard-paste = "Control+Shift+v XF86Paste";
        quit = "Control+q";
      };
    };
  };
}
