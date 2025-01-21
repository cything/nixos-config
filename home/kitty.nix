{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    font = {
      name = "IBM Plex Mono";
      package = pkgs.ibm-plex;
      size = 12;
    };
    themeFile = "GitHub_Dark";
    settings = {
      enable_audio_bell = false;
      # how many windows should be open before kitty asks
      # for confirmation
      confirm_os_window_close = 0;
    };
    keybindings = {
      # kitty_mod is ctrl+shift by default
      "kitty_mod+c" = "copy_to_clipboard";
      "kitty_mod+v" = "paste_from_clipboard";
      "ctrl+q" = "quit";

      # windows
      "kitty_mod+h" = "neighboring_window left";
      "kitty_mod+alt+h" = "move_window left";
      "kitty_mod+l" = "neighboring_window right";
      "kitty_mod+alt+l" = "move_window right";
      "kitty_mod+j" = "neighboring_window down";
      "kitty_mod+alt+j" = "move_window down";
      "kitty_mod+k" = "neighboring_window up";
      "kitty_mod+alt+k" = "move_window up";
      "ctrl+f2" = "detach_tab";
      "ctrl+f3" = "detach_window new-tab";
      "ctrl+f4" = "detach_window prev-tab";
      "ctrl+alt+l" = "next_layout";
      "ctrl+alt+t" = "goto_layout tall";
      "ctrl+alt+s" = "goto_layout stack";

      # tabs
      "kitty_mod+n" = "next_tab";
      "kitty_mod+p" = "previous_tab";
      "kitty_mod+alt+n" = "move_tab_forward";
      "kitty_mod+alt+p" = "move_tab_backward";
      "kitty_mod+w" = "close_tab";
    };
  };
}
