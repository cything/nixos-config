{ inputs }:
let
  overlays = [
    ./zipline
    ./bitwarden
  ];
  importedOverlays = map (m: import m) overlays;
in
[
  (
    final: prev:
    let
      nixpkgsFrom = flake: pkg: flake.legacyPackages.${prev.system}.${pkg};
      pkgFrom = flake: pkg: flake.packages.${prev.system}.${pkg};
    in
    {
      conduwuit =
       pkgFrom inputs.conduwuit "static-x86_64-linux-musl-all-features-x86_64-haswell-optimised";
      pixelflasher = nixpkgsFrom inputs.pixelflasher "pixelflasher";
      attic-server = pkgFrom inputs.attic "attic-server";
      attic = pkgFrom inputs.attic "attic";
    }
  )
]
++ importedOverlays