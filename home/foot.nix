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
      };
      mouse = {
        hide-when-typing = "yes";
      };
      colors = {
        background = "161821";
        foreground = "c6c8d1";

        selection-background = "1e2132";
        selection-foreground = "c6c8d1";

        regular0 = "161821";
        bright0 = "6b7089";

        regular1 = "e27878";
        bright1 = "e98989";

        regular2 = "b4be82";
        bright2 = "c0ca8e";

        regular3 = "e2a478";
        bright3 = "e9b189";

        regular4 = "84a0c6";
        bright4 = "91acd1";

        regular5 = "a093c7";
        bright5 = "ada0d3";

        regular6 = "89b8c2";
        bright6 = "95c4ce";

        regular7 = "c6c8d1";
        bright7 = "d2d4de";
      };

      key-bindings = {
        clipboard-copy = "Control+Shift+c XF86Copy";
        clipboard-paste = "Control+Shift+v XF86Paste";
        quit = "Control+q";
      };
    };
  };
}
