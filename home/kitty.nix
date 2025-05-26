{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "IBM Plex Mono";
      package = pkgs.ibm-plex;
      size = 12;
    };
    settings = {
      enable_audio_bell = true;
      # how many windows should be open before kitty asks
      # for confirmation
      confirm_os_window_close = 0;
      clear_all_shortcuts = true;
      background_opacity = 0.9;

      # will probably lower this later but the max allowed is actually 4GB
      # this is NOT stored in memory and can only be viewed with scrollback_pager
      "scrollback_pager_history_size" = "10"; # in MB
      # see https://github.com/sharkdp/bat/issues/1077#issuecomment-652785399
      "scrollback_pager" = "bat --pager='less -FR +G'";
      # "scrollback_lines" = 20000;
      wheel_scroll_multiplier = 50;
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
      # this closes the *current* window, not the *OS* window
      # https://sw.kovidgoyal.net/kitty/overview/#tabs-and-windows
      "kitty_mod+w" = "close_window";

      # tabs
      "kitty_mod+n" = "next_tab";
      "kitty_mod+p" = "previous_tab";
      "kitty_mod+alt+n" = "move_tab_forward";
      "kitty_mod+alt+p" = "move_tab_backward";
      "kitty_mod+q" = "close_tab";
      "kitty_mod+t" = "new_tab_with_cwd";

      # hints
      # > basically means the preceding key is a prefix (think tmux)
      "kitty_mod+o>o" = "open_url_with_hints";
      # `--program @` means copy to clipboard
      "kitty_mod+o>u" = "kitten hints --type url --program @";
      "kitty_mod+o>p" = "kitten hints --type path --program @";
      "kitty_mod+o>n" = "kitten hints --type line --program @";
      "kitty_mod+o>w" = "kitten hints --type word --program @";
      "kitty_mod+o>h" = "kitten hints --type hash --program @";
      "kitty_mod+o>l" = "kitten hints --type linenum";

      # scrolling
      "kitty_mod+u" = "scroll_page_up";
      "kitty_mod+d" = "scroll_page_down";
      "kitty_mod+a" = "scroll_home";
      "kitty_mod+e" = "scroll_end";
      "kitty_mod+z" = "scroll_to_prompt -1"; # scroll to previous shell prompt
      "kitty_mod+x" = "scroll_to_prompt 1"; # scroll to next shell prompt
      "kitty_mod+y" = "show_scrollback"; # browse scrollback buffer in pager
      "kitty_mod+g" = "show_last_command_output"; # browse output of last command in pager
    };
  };

  programs.zsh.shellAliases."ssh" = "kitten ssh";
}
