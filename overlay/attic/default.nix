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
              rev = "d660c85bdb6bb10499a23a846a13107ea0c72769";
              hash = "sha256-E22d2OLV02L2QdiSeK58flveehR8z8WIKkcN/njAMdg=";
            };
            cargoLock = null;
            cargoHash = "sha256-AbpWnYfBMrR6oOfy2LkQvIPYsClCWE89bJav+iHTtLM=";
            useFetchCargoVendor = true;
            patches = [
              ./concurrent-32.patch
            ];
          }
        );
    };
  });
}
