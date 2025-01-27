inputs: let
  overlays = [
    ./conduwuit
    ./attic
  ];
  importedOverlays = map (m: import m) overlays;
in
importedOverlays ++ [
  (import ./anki.nix inputs)
]
