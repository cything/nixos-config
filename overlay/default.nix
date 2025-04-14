{ inputs }:
[
  (
    final: prev:
    let
      nixpkgsFrom = flake: pkg: flake.legacyPackages.${prev.system}.${pkg};
      pkgFrom = flake: pkg: flake.packages.${prev.system}.${pkg};
    in
    {
      garage = (
        (pkgFrom inputs.garage "default").overrideAttrs {
          meta.mainProgram = "garage";
        }
      );
    }
  )
]
