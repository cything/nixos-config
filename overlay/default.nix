{ inputs }:
let
  overlays = [
    ./zipline
    ./bitwarden
    ./attic
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
      conduwuit = pkgFrom inputs.conduwuit "default";
      pixelflasher = nixpkgsFrom inputs.pixelflasher "pixelflasher";
      attic-server = pkgFrom inputs.attic "attic-server";
      attic = pkgFrom inputs.attic "attic";
      garage = (
        (pkgFrom inputs.garage "default").overrideAttrs {
          meta.mainProgram = "garage";
        }
      );
      helix = pkgFrom inputs.helix "default";
    }
  )
]
++ importedOverlays
