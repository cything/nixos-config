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
              rev = "e91261dc9a22d267700ab9095155f5581ac3b06c";
              hash = "sha256-dIrCD0rLXlW1XsNiF50vTeHi1l4xHYh0m+aCdHNcMfU=";
            };
            cargoLock = null;
            cargoHash = "sha256-AbpWnYfBMrR6oOfy2LkQvIPYsClCWE89bJav+iHTtLM=";
            useFetchCargoVendor = true;
          }
        );
    };
  });
}
