final: prev: {
  conduwuit = prev.conduwuit.override (old: {
    rustPlatform = old.rustPlatform // {
      buildRustPackage =
        args:
        old.rustPlatform.buildRustPackage (
          args
          // rec {
            version = "0.5.0-rc2";
            src = final.fetchFromGitHub {
              owner = "girlbossceo";
              repo = "conduwuit";
              rev = "v${version}";
              hash = "sha256-xnwqhU3yOIyWRrD/Pq3jmUHoNZSY8Ms9h8OTsZVYQ1g=";
            };
            doCheck = false;
            cargoHash = "sha256-ZenMTCEJrALKQnW7/eXqrhFj+BedE9i/rQZMsPHl8K0=";
            cargoPatches = [
              ./fix-lint.patch
            ];
            # unstable has this set to "conduit"
            meta.mainProgram = "conduwuit";
          }
        );
    };
  });
}
