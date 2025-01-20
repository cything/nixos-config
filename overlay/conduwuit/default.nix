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
              rev = "5b8464252c2c03edf65e43153be026dbb768a12a";
              hash = "sha256-yNdxoVZX13QUDJYM6zTMY9ExvacTqB+f0MLvDreSW8U=";
            };
            doCheck = false;
            cargoHash = "sha256-g19UujLI9d4aw+1273gfC17LDLOciqBvuLhe/VCsh80=";
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
