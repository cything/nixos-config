{ ... }:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    clearDefaultKeybinds = true;
    settings = {
      theme = "iceberg-dark";
      font-family = "IBM Plex Mono";
      font-size = "12";
      window-decoration = false;
      confirm-close-surface = false;
      keybind = [
        "ctrl+q=quit"
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
      ];
    };
  };
}
