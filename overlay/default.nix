let
  overlays = [
    ./conduwuit
    ./attic
    ./sway.nix
  ];
  importedOverlays = map (m: import m) overlays;
in
importedOverlays
