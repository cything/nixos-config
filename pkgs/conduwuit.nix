{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  bzip2,
  zstd,
  stdenv,
  apple-sdk_15,
  darwinMinVersionHook,
  rocksdb,
  nix-update-script,
  testers,
  conduwuit,
  # upstream conduwuit enables jemalloc by default, so we follow suit
  enableJemalloc ? true,
  rust-jemalloc-sys,
  enableLiburing ? stdenv.hostPlatform.isLinux,
  liburing,
  nixosTests,
}:
let
  rust-jemalloc-sys' = rust-jemalloc-sys.override {
    unprefixed = !stdenv.hostPlatform.isDarwin;
  };
  rocksdb' = rocksdb.override {
    inherit enableLiburing;
    # rocksdb does not support prefixed jemalloc, which is required on darwin
    enableJemalloc = enableJemalloc && !stdenv.hostPlatform.isDarwin;
    jemalloc = rust-jemalloc-sys';
  };
in
rustPlatform.buildRustPackage rec {
  pname = "conduwuit";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "girlbossceo";
    repo = "conduwuit";
    rev = "58be22e69557f7045ad3fd433a438b33150ecd83";
    hash = "sha256-pHMD8JRCHO0vRp7M5SPy2Ag6YbvHubwwRCjdskriN8I=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-T55avmRKq3j6G+WxlTCEqTzF5Lbh0qsk9WVxocVhtIM=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs =
    [
      bzip2
      zstd
    ]
    ++ lib.optional enableJemalloc rust-jemalloc-sys'
    ++ lib.optional enableLiburing liburing
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      apple-sdk_15
      # aws-lc-sys requires CryptoKit's CommonCrypto, which is available on macOS 10.15+
      (darwinMinVersionHook "10.15")
    ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
    ROCKSDB_INCLUDE_DIR = "${rocksdb'}/include";
    ROCKSDB_LIB_DIR = "${rocksdb'}/lib";
  };

  buildNoDefaultFeatures = true;
  # See https://github.com/girlbossceo/conduwuit/blob/main/src/main/Cargo.toml
  # for available features.
  # We enable all default features except jemalloc and io_uring, which
  # we guard behind our own (default-enabled) flags.
  buildFeatures = [
    "brotli_compression"
    "element_hacks"
    "gzip_compression"
    "release_max_log_level"
    "sentry_telemetry"
    "systemd"
    "zstd_compression"
  ] ++ lib.optional enableJemalloc "jemalloc" ++ lib.optional enableLiburing "io_uring";

  passthru = {
    updateScript = nix-update-script { };
    tests =
      {
        version = testers.testVersion {
          inherit version;
          package = conduwuit;
        };
      }
      // lib.optionalAttrs stdenv.hostPlatform.isLinux {
        inherit (nixosTests) conduwuit;
      };
  };

  meta = {
    description = "Matrix homeserver written in Rust, forked from conduit";
    homepage = "https://conduwuit.puppyirl.gay/";
    changelog = "https://github.com/girlbossceo/conduwuit/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ niklaskorz ];
    # Not a typo, conduwuit is a drop-in replacement for conduit.
    mainProgram = "conduit";
  };
}
