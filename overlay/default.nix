{ inputs }:
let
  overlays = [
    ./attic
  ];
  importedOverlays = map (m: import m) overlays;
in
importedOverlays
++ [
  (
    final: prev:
    let
      pkgFrom = flake: pkg: flake.legacyPackages.${prev.system}.${pkg};
      stable = inputs.nixpkgs-stable;
    in
    {
      conduwuit = inputs.conduwuit.packages.x86_64-linux.static-x86_64-linux-musl-all-features-x86_64-haswell-optimised;
    }
  )
]
