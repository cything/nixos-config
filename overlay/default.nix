let
  overlays = [
    ./conduwuit
    ./attic
    ./kernel.nix
  ];
  importedOverlays = map (m: import m) overlays;
in
importedOverlays
