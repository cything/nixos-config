final: prev: {
  conduwuit = prev.conduwuit.override (old: {
    rustPlatform = old.rustPlatform // {
      buildRustPackage =
        args:
        old.rustPlatform.buildRustPackage (
          args
          // {
            version = "0.5.0-rc2";
            src = final.fetchFromGitHub {
              owner = "girlbossceo";
              repo = "conduwuit";
              rev = "8c74e35e7640a041c1f3496d82585e5240294352";
              hash = "sha256-/2YD3TXT9pQ7oPEm9wDrq35afU88qukMIWqrBX5JyXg=";
            };
            doCheck = false;
            cargoHash = "sha256-ZenMTCEJrALKQnW7/eXqrhFj+BedE9i/rQZMsPHl8K0=";
            cargoPatches = [
              ./fix-lint.patch
            ];
            # unstable has this set to "conduit"
            meta.mainProgram = "conduwuit";

            buildFeatures = [
              "brotli_compression"
              "element_hacks"
              "gzip_compression"
              "release_max_log_level" # without this feature to enable debug logging
              "sentry_telemetry"
              "systemd"
              "zstd_compression"
              "jemalloc"
              "io_uring"
            ];
          }
        );
    };
  });
}
