{ inputs }: let
  overlays = [
    ./conduwuit
    ./attic
    ./vscode.nix
  ];
  importedOverlays = map (m: import m) overlays;
in
importedOverlays
++
[
  (final: prev:
    let
      pkgFrom = flake: pkg: flake.legacyPackages.${prev.system}.${pkg};
      stable = inputs.nixpkgs-stable;
    in
    {
      bitwarden-cli = pkgFrom stable "bitwarden-cli";
      roundcube = pkgFrom stable "roundcube";
      lldb = pkgFrom stable "lldb";
      calibre = pkgFrom stable "calibre";
    }
  )
]
