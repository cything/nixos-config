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
              rev = "3e0c381aa1b4f41234284b5491aa818c24af5983";
              hash = "sha256-kw7zeQH+mg0bCTzfr6MqlqAHzYfPSlNj2Fk+lRqVO7A=";
            };
            cargoLock = null;
            cargoHash = "sha256-0z7cFMMltJQt3zBQ0L+t8MLKPE+HtduWJnNXED7rEHc=";
            useFetchCargoVendor = true;
          }
        );
    };
  });
}
