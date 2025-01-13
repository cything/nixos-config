{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      jnoortheen.nix-ide # nix language support
      editorconfig.editorconfig # editorconfig
      dracula-theme.theme-dracula # color scheme
      tomoki1207.pdf # pdf viewer
      yzhang.markdown-all-in-one # markdown tools
    ];
  };
}
