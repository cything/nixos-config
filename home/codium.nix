{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    mutableExtensionsDir = false;
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions =
        # if unfree
        # with pkgs.vscode-marketplace;
        with pkgs.open-vsx; [
          vscodevim.vim
          jnoortheen.nix-ide
          github.github-vscode-theme
          rust-lang.rust-analyzer
          shd101wyy.markdown-preview-enhanced
          fwcd.kotlin
        ];
      userSettings = {
        "workbench.colorTheme" = "GitHub Dark Default";
        "files.autoSave" = "afterDelay";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "editor.fontFamily" = "IBM Plex Mono";
        "editor.fontSize" = 16;
        "editor.wordWrap" = "on";

        # vim mode settings
        "vim.handleKeys" = {
          "<C-b>" = false; # file tree toggle
        };
        "vim.normalModeKeyBindings" = [
          {
            "before" = [ ";" ];
            "after" = [ ":" ];
            "silent" = true;
          }
        ];
        "workbench.startupEditor" = "none";
      };
    };
  };
}
