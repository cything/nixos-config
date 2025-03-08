{ inputs }:
let
  overlays = [
    ./attic
    ./zipline
  ];
  importedOverlays = map (m: import m) overlays;
in
importedOverlays
++ [
  (
    final: prev:
    let
      nixpkgsFrom = flake: pkg: flake.legacyPackages.${prev.system}.${pkg};
      pkgFrom = flake: pkgFrom' flake "default";
      pkgFrom' = flake: pkg: flake.packages.${prev.system}.${pkg};
    in
    {
      conduwuit =
       pkgFrom' inputs.conduwuit "static-x86_64-linux-musl-all-features-x86_64-haswell-optimised";
      pixelflasher = nixpkgsFrom inputs.pixelflasher "pixelflasher";
    }
  )
]