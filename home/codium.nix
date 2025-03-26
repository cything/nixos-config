{ pkgs, lib, ... }:
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
          alefragnani.bookmarks
          tomrijndorp.find-it-faster
          streetsidesoftware.code-spell-checker
          emilast.logfilehighlighter
          tamasfe.even-better-toml
          golang.go
          ms-python.python
          christian-kohler.path-intellisense
        ];
      userSettings =
        let
          vimCommonKeyBindings = [
            # nice emacs bindings
            {
              "before" = [ "C-a" ];
              "commands" = [ "cursorHome" ];
            }
            {
              "before" = [ "C-e" ];
              "commands" = [ "cursorEnd" ];
            }
            {
              "before" = [ "C-b" ];
              "commands" = [ "cursorLeft" ];
            }
            {
              "before" = [ "C-f" ];
              "commands" = [ "cursorRight" ];
            }
            # ctrl+h to turn off search highlighting
            {
              "before" = [ "C-h" ];
              "commands" = [ ":nohl" ];
            }
          ];
        in
        {
          "workbench.colorTheme" = "GitHub Dark Default";
          "workbench.startupEditor" = "none";
          "workbench.enableExperiments" = false;
          "files.autoSave" = "onFocusChange";
          "editor.fontFamily" = "IBM Plex Mono";
          "editor.fontSize" = 15;
          "editor.minimap.enabled" = false;
          "window.zoomLevel" = 0.5;
          "security.promptForLocalFileProtocolHandling" = false;
          "security.promptForRemoteFileProtocolHandling" = false;
          "explorer.confirmDelete" = false;
          "explorer.confirmDragAndDrop" = false;
          "editor.acceptSuggestionOnEnter" = "off";
          "editor.acceptSuggestionOnCommitCharacter" = false;
          "git.openRepositoryInParentFolders" = "never";
          "git.ignoreLimitWarning" = true;
          "git.blame.editorDecoration.enabled" = true;
          "extensions.ignoreRecommendations" = true;
          "telemetry.enableTelemetry" = false;
          "telemetry.telemetryLevel" = "off";
          "window.titleBarStyle" = "custom";

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

          "markdown-preview-enhanced.previewTheme" = "github-dark.css";
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "${lib.getExe pkgs.nil}";
          "bookmarks.saveBookmarksInProject" = true;

          "cSpell.enabledFileTypes" = {
            "markdown" = true;
            "*" = false;
          };

          # vim stuff
          "vim.leader" = ",";
          "extensions.experimental.affinity" = {
            "vscodevim.vim" = 1;
          };
          "vim.sneak" = true;
          "vim.sneakUseIgnorecaseAndSmartcase" = true;
          "vim.enableNeovim" = true;
          "vim.hlsearch" = true;
          "vim.easymotion" = true;
          "editor.lineNumbers" = "relative";
          "vim.normalModeKeyBindings" = vimCommonKeyBindings ++ [
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
                "<space>"
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
            # insert line without leaving normal mode
            {
              "before" = [
                "<space>"
                "o"
              ];
              "commands" = [ "editor.action.insertLineAfter" ];
            }
            {
              "before" = [
                "<space>"
                "O"
              ];
              "commands" = [ "editor.action.insertLineBefore" ];
            }
          ];
          "vim.insertModeKeyBindings" = vimCommonKeyBindings ++ [
            {
              "before" = [ "C-k" ];
              "commands" = [ "acceptSelectedSuggestion" ];
            }
          ];
          "vim.visualModeKeyBindings" = vimCommonKeyBindings ++ [
            {
              "before" = [ ">" ];
              "commands" = [ "editor.action.indentLines" ];
            }
            {
              "before" = [ "<" ];
              "commands" = [ "editor.action.outdentLines" ];
            }
          ];
        };
      keybindings = [
        # repeat these vim bindings here cause otherwise they get overridden by vscode
        {
          "key" = "ctrl+b";
          "when" = "inputFocus";
          "command" = "cursorLeft";
        }
        {
          "key" = "ctrl+f";
          "when" = "inputFocus";
          "command" = "cursorRight";
        }
        # clear default bindings that conflict
        {
          "key" = "ctrl+f";
          "command" = "-actions.find";
        }
        {
          "key" = "ctrl+b";
          "command" = "-workbench.action.toggleSidebarVisibility";
        }
        {
          "key" = "ctrl+w";
          "command" = "-workbench.action.closeActiveEditor";
        }
      ];
    };
  };
}
