final: prev: {
  attic-client = prev.attic-client.override (old: {
    rustPlatform = old.rustPlatform // {
      buildRustPackage =
        args:
        old.rustPlatform.buildRustPackage (
          args
          // {
            version = "0.1.1";
            src = final.fetchFromGitHub {
              owner = "cything";
              repo = "attic";
              rev = "ef9a067d84dcf02e280bb82796a2e0ee6177a34d";
              hash = "sha256-BLY/RiyQfSgzxu6TDIzkE2mRT3YI5llJc35j57C8Os4=";
            };
            cargoLock = null;
            cargoHash = "sha256-AbpWnYfBMrR6oOfy2LkQvIPYsClCWE89bJav+iHTtLM=";
            useFetchCargoVendor = true;
          }
        );
    };
  });
}
