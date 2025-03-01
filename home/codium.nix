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
          streetsidesoftware.code-spell-checker
        ];
      userSettings = {
        "workbench.colorTheme" = "GitHub Dark Default";
        "files.autoSave" = "onFocusChange";
        "editor.fontFamily" = "IBM Plex Mono";
        "editor.fontSize" = 15;
        "window.zoomLevel" = 0.5;
        "security.promptForLocalFileProtocolHandling" = false;
        "security.promptForRemoteFileProtocolHandling" = false;
        "markdown-preview-enhanced.previewTheme" = "github-dark.css";
        "editor.minimap.enabled" = false;
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "editor.acceptSuggestionOnEnter" = "off";
        "editor.acceptSuggestionOnCommitCharacter" = false;
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

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";

        "cSpell.enabledFileTypes" = {
          "markdown" = true;
          "*" = false;
        };

        # vim stuff
        "vim.leader" = ",";
        "vim.normalModeKeyBindings" = [
          {
            "before" = [ ";" ];
            "after" = [ ":" ];
            "silent" = true;
          }
          {
            "before" = [
              "<leader>"
              "m"
            ];
            "commands" = [ "bookmarks.toggle" ];
          }
          {
            "before" = [
              "<leader>"
              "l"
            ];
            "commands" = [ "bookmarks.toggleLabeled" ];
          }
          {
            "before" = [
              "<leader>"
              "b"
            ];
            "commands" = [ "bookmarks.list" ];
          }
          {
            "before" = [
              "<leader>"
              "s"
            ];
            "commands" = [ "workbench.action.toggleSidebarVisibility" ];
          }
          {
            "before" = [
              "<leader>"
              "f"
              "f"
            ];
            "commands" = [ "find-it-faster.findFiles" ];
          }
          {
            "before" = [
              "<leader>"
              "f"
              "g"
            ];
            "commands" = [ "find-it-faster.findWithinFiles" ];
          }
          {
            "before" = [
              "<leader>"
              "f"
              "t"
            ];
            "commands" = [ "find-it-faster.findWithinFilesWithType" ];
          }
          # "gd" for definitions is by default
          {
            "before" = [
              "g"
              "r"
            ];
            "commands" = [ "editor.action.goToReferences" ];
          }
          # the default is weird when you need to go back within a file
          {
            "before" = [ "C-o" ];
            "commands" = [ "workbench.action.navigateBack" ];
          }
          {
            "before" = [ "C-i" ];
            "commands" = [ "workbench.action.navigateForward" ];
          }
        ];
        "vim.insertModeKeyBindings" = [
          {
            "before" = [ "C-a" ];
            "commands" = [ "cursorHome" ];
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
      };
    };
  };
}
