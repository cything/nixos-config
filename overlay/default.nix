let
  overlays = [
    ./conduwuit
    ./attic
    ./vscode.nix
  ];
  importedOverlays = map (m: import m) overlays;
in
importedOverlays
