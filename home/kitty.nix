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
      clear_all_shortcuts = true;

      # will probably lower this later but the max allowed is actually 4GB
      # this is NOT stored in memory and can only be viewed wth scrollback_pager
      "scrollback_pager_history_size" = "1024";
      # see https://github.com/sharkdp/bat/issues/1077#issuecomment-652785399
      "scrollback_pager" = "bat --pager='less -FR +G'";
    };
    keybindings = {
      # kitty_mod is ctrl+shift by default
      "kitty_mod+c" = "copy_to_clipboard";
      "kitty_mod+v" = "paste_from_clipboard";
      # "ctrl+q" = "quit";

      "kitty_mod+m" = "show_scrollback";

      # windows
      "kitty_mod+h" = "neighboring_window left";
      "kitty_mod+alt+h" = "move_window left";
      "kitty_mod+l" = "neighboring_window right";
      "kitty_mod+alt+l" = "move_window right";
      "kitty_mod+j" = "neighboring_window down";
      "kitty_mod+alt+j" = "move_window down";
      "kitty_mod+k" = "neighboring_window up";
      "kitty_mod+alt+k" = "move_window up";
      "ctrl+f3" = "detach_window new-tab";
      "ctrl+f4" = "detach_window tab-left";
      "ctrl+f5" = "load_config_file";
      "ctrl+alt+l" = "next_layout";
      "ctrl+alt+t" = "goto_layout tall";
      "ctrl+alt+s" = "goto_layout stack";
      "kitty_mod+enter" = "new_window_with_cwd";
      "kitty_mod+r" = "resize_window";

      # tabs
      "kitty_mod+n" = "next_tab";
      "kitty_mod+p" = "previous_tab";
      "kitty_mod+alt+n" = "move_tab_forward";
      "kitty_mod+alt+p" = "move_tab_backward";
      "kitty_mod+w" = "close_tab";
      "kitty_mod+t" = "new_tab_with_cwd";
      "ctrl+f2" = "detach_tab";

      # hints
      "kitty_mod+o>o" = "open_url_with_hints";
      "kitty_mod+o>p" = "kitten hints --type path --program -";
      "kitty_mod+o>n" = "kitten hints --type line --program -";
      "kitty_mod+o>w" = "kitten hints --type word --program -";
      "kitty_mod+o>h" = "kitten hints --type hash --program -";
      "kitty_mod+o>l" = "kitten hints --type linenum";
    };
  };
}
