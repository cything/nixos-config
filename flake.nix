{
  description = "cy's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.crane.follows = "crane";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-parts.follows = "flake-parts";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-compat.follows = "flake-compat";
      inputs.home-manager.follows = "home-manager";
      inputs.treefmt-nix.follows = "treefmt";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    conduwuit = {
      url = "github:girlbossceo/conduwuit";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "crane";
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
      };
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.lix.follows = "lix";
    };
    lix = {
      url = "git+https://git.lix.systems/lix-project/lix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-rpi.url = "github:nixos/nixpkgs/d4e529a24b66b0341f2b866c5abe3ad8a96be2d7";
    nixpkgs-garage.url = "github:cything/nixpkgs/garage-module"; # unmerged PR

    nvim-github-theme = {
      url = "github:projekt0n/github-nvim-theme";
      flake = false;
    };

    # deduplication
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
    flake-compat.url = "github:edolstra/flake-compat";
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.cything.io/central"
      "https://niri.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
      "https://cything.cachix.org"
    ];
    extra-trusted-public-keys = [
      "central:uWhjva6m6dhC2hqNisjn2hXGvdGBs19vPkA1dPEuwFg="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cything.cachix.org-1:xqW1W5NNL+wrM9wfSELb0MLj/harD2ZyB4HbdaMyvPI="
    ];
    builders-use-substitutes = true;
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [
          inputs.treefmt.flakeModule
        ];
        debug = true;
        systems = [
          "x86_64-linux"
        ];
        perSystem =
          {
            inputs',
            ...
          }:
          {
            # make pkgs available to `perSystem`
            _module.args.pkgs = inputs'.nixpkgs.legacyPackages;

            treefmt = {
              projectRootFile = "flake.nix";
              programs.nixfmt.enable = true;
              programs.stylua.enable = true;
              programs.yamlfmt.enable = true;
              programs.typos.enable = true;
              programs.shellcheck.enable = true;

              settings.global.excludes = [
                "secrets/*"
                "**/*.png" # tries to format a png file??
              ];
            };
          };

        flake =
          let
            pkgsFor = system: import nixpkgs {
              config.allowUnfree = true;
              system = system;
              overlays = [
                inputs.niri.overlays.niri
                inputs.rust-overlay.overlays.default
              ] ++ import ./overlay;
            };
          in
          {
            nixosConfigurations =
              let
                lib = nixpkgs.lib;
              in
              {
                ytnix = lib.nixosSystem {
                  specialArgs = { inherit inputs; };
                  modules = [
                    {
                      nixpkgs.pkgs = pkgsFor "x86_64-linux";
                    }
                    ./hosts/ytnix
                    inputs.sops-nix.nixosModules.sops
                    ./modules
                    inputs.lanzaboote.nixosModules.lanzaboote
                    inputs.niri.nixosModules.niri
                    # inputs.lix-module.nixosModules.default # broken
                  ];
                };
                chunk = lib.nixosSystem {
                  specialArgs = { inherit inputs; };
                  modules = [
                    {
                      nixpkgs.pkgs = pkgsFor "x86_64-linux";
                      disabledModules = [
                        "services/web-servers/garage.nix"
                      ];
                    }
                    ./hosts/chunk
                    inputs.sops-nix.nixosModules.sops
                    ./modules
                    (inputs.nixpkgs-garage + "/nixos/modules/services/web-servers/garage.nix")
                  ];
                };

                titan = lib.nixosSystem {
                  specialArgs = { inherit inputs; };
                  modules = [
                    {
                      nixpkgs.pkgs = pkgsFor "x86_64-linux";
                    }
                    ./hosts/titan
                    disko.nixosModules.disko
                    inputs.sops-nix.nixosModules.sops
                    ./modules
                  ];
                };

                pancake = lib.nixosSystem {
                  specialArgs = { inherit inputs; };
                  modules = [
                    {
                      nixpkgs.pkgs = pkgsFor "aarch64-linux";
                    }
                    inputs.nixos-hardware.nixosModules.raspberry-pi-3
                    inputs.nixos-generators.nixosModules.all-formats
                    ./hosts/pancake
                    ./modules
                  ];
                };
              };
            homeConfigurations =
              let
                lib = home-manager.lib;
              in
              {
                "yt@ytnix" = lib.homeManagerConfiguration {
                  pkgs = pkgsFor "x86_64-linux";
                  extraSpecialArgs = { inherit inputs; };
                  modules = [
                    ./home/yt/ytnix.nix
                    inputs.nixvim.homeManagerModules.nixvim
                    inputs.niri.homeModules.config
                  ];
                };

                "yt@chunk" = lib.homeManagerConfiguration {
                  pkgs = pkgsFor "x86_64-linux";
                  extraSpecialArgs = { inherit inputs; };
                  modules = [
                    ./home/yt/chunk.nix
                    inputs.nixvim.homeManagerModules.nixvim
                  ];
                };

                "codespace@codespace" = lib.homeManagerConfiguration {
                  pkgs = pkgsFor "x86_64-linux";
                  extraSpecialArgs = { inherit inputs; };
                  modules = [
                    ./home/yt/codespace.nix
                    inputs.nixvim.homeManagerModules.nixvim
                  ];
                };
              };
          };
      }
    );
}
