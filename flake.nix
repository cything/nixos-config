{
  description = "cy's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
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
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
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
        attic.follows = "attic";
      };
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-ld = {
      url = "github:nix-community/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-utils.follows = "flake-utils";
    };
    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions/";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pixelflasher.url = "github:cything/nixpkgs/pixelflasher";
    attic = {
      url = "github:zhaofengli/attic";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        crane.follows = "crane";
      };
    };
    garage = {
      url = "github:deuxfleurs-org/garage";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
        crane.follows = "crane";
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
      };
    };

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
      "https://nix-community.cachix.org"
      "https://cdn.cy7.sh/main"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "main:Ku31HoEWcBtfggge2VGj+QTkVrQuIwRIMGyfV/5VQP0="
    ];
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
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
            treefmt = {
              projectRootFile = "flake.nix";
              programs.nixfmt.enable = true;
              programs.stylua.enable = true;
              programs.yamlfmt.enable = true;
              programs.typos.enable = true;
              programs.shellcheck.enable = true;

              settings.global.excludes = [
                "secrets/*"
                "**/*.png" # tries to format a png file
              ];
            };
          };

        flake =
          let
            pkgs = import nixpkgs {
              config.allowUnfree = true;
              system = "x86_64-linux";
              overlays = [
                inputs.rust-overlay.overlays.default
                inputs.vscode-extensions.overlays.default
              ] ++ (import ./overlay { inherit inputs; });
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
                      nixpkgs = { inherit pkgs; };
                    }
                    ./hosts/ytnix
                    ./modules
                    inputs.sops-nix.nixosModules.sops
                    inputs.lanzaboote.nixosModules.lanzaboote
                    inputs.lix-module.nixosModules.default
                    inputs.nix-ld.nixosModules.nix-ld
                  ];
                };
                chunk = lib.nixosSystem {
                  specialArgs = { inherit inputs; };
                  modules = [
                    {
                      nixpkgs = { inherit pkgs; };
                    }
                    ./hosts/chunk
                    ./modules
                    inputs.sops-nix.nixosModules.sops
                    inputs.lix-module.nixosModules.default
                  ];
                };
              };
            homeConfigurations =
              let
                lib = home-manager.lib;
              in
              {
                "yt@ytnix" = lib.homeManagerConfiguration {
                  inherit pkgs;
                  extraSpecialArgs = { inherit inputs; };
                  modules = [
                    ./home/yt/ytnix.nix
                    inputs.nixvim.homeManagerModules.nixvim
                    inputs.nix-index-database.hmModules.nix-index
                  ];
                };

                "yt@chunk" = lib.homeManagerConfiguration {
                  inherit pkgs;
                  extraSpecialArgs = { inherit inputs; };
                  modules = [
                    ./home/yt/chunk.nix
                    inputs.nixvim.homeManagerModules.nixvim
                  ];
                };
              };
          };
      }
    );
}
