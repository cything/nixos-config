let
  overlays = [
    ./conduwuit
  ];
  importedOverlays = map (m: import m) overlays;
in
  importedOverlays
