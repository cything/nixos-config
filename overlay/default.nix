{ inputs }:
[
  (
    final: prev:
    let
      nixpkgsFrom = flake: pkg: flake.legacyPackages.${prev.system}.${pkg};
      pkgFrom = flake: pkg: flake.packages.${prev.system}.${pkg};
    in
    {
      conduwuit = pkgFrom inputs.conduwuit "default";
      attic-server = pkgFrom inputs.attic "attic-server";
      attic = pkgFrom inputs.attic "attic";
      garage = (
        (pkgFrom inputs.garage "default").overrideAttrs {
          meta.mainProgram = "garage";
        }
      );
      nil = pkgFrom inputs.nil "default";
    }
  )
]
