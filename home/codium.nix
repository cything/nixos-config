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
          alefragnani.bookmarks
          tomrijndorp.find-it-faster
        ];
      userSettings = {
        "workbench.colorTheme" = "GitHub Dark Default";
        "files.autoSave" = "onFocusChange";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "editor.fontFamily" = "IBM Plex Mono";
        "editor.fontSize" = 15;
        "window.zoomLevel" = 0.5;

        # vim mode settings
        "vim.leader" = ",";
        "vim.normalModeKeyBindings" = [
          {
            "before" = [ ";" ];
            "after" = [ ":" ];
            "silent" = true;
          }
          {
            "before" = [ "<leader>" "m" ];
            "commands" = [ "bookmarks.toggle" ];
          }
          {
            "before" = [ "<leader>" "l" ];
            "commands" = [ "bookmarks.toggleLabeled" ];
          }
          {
            "before" = [ "<leader>" "b" ];
            "commands" = [ "bookmarks.list" ];
          }
          {
            "before" = [ "<leader>" "s" ];
            "commands" = [ "workbench.action.toggleSidebarVisibility" ];
          }
          {
            "before" = [ "<leader>" "f" "f" ];
            "commands" = [ "find-it-faster.findFiles" ];
          }
          {
            "before" = [ "<leader>" "f" "g"];
            "commands" = [ "find-it-faster.findWithinFiles"];
          }
          {
            "before" = [ "<leader>" "f" "t"];
            "commands" = [ "find-it-faster.findWithinFilesWithType"];
          }
        ];
        "vim.insertModeKeyBindings" = [
          {
            "before" = [ "C-a" ];
            "commands"  = [ "cursorHome" ];
          }
          {
            "before" = [ "C-e" ];
            "commands" = [ "cursorEnd" ];
          }
        ];
        "vim.visualModeKeyBindings" = [
          {
            "before" = [ ">" ];
            "commands" = [ "editor.action.indentLines" ];
          }
          {
            "before" = [ "<" ];
            "commands" = [ "editor.action.outdentLines" ];
          }
        ];
        "extensions.experimental.affinity" = {
          "vscodevim.vim" = 1;
        };
        "workbench.startupEditor" = "none";
        "git.openRepositoryInParentFolders" = "never";
        
        # terminal stuff
        "terminal.integrated.cursorBlinking" = true;
        "terminal.integrated.cursorStyle" = "line";
        "terminal.integrated.customGlyphs" = false;
        "terminal.integrated.env.linux" = {
          # https://github.com/tomrijndorp/vscode-finditfaster/issues/112#issuecomment-2475227546
          FZF_DEFAULT_OPTS = "--bind ctrl-n:down,ctrl-p:up";
        };
        # don't let the workbench handle terminal keys like ctrl+n and friends
	      "terminal.integrated.sendKeybindingsToShell" = true;
        "terminal.integrated.allowChords" = false;
      };
    };
  };
}
