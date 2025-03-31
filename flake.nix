{
  description = "cy's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager.url = "github:nix-community/home-manager";
    lanzaboote.url = "github:nix-community/lanzaboote/master";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay.url = "github:oxalica/rust-overlay";
    conduwuit.url = "github:girlbossceo/conduwuit";
    lix-module.url = "git+https://git.lix.systems/lix-project/nixos-module";
    nix-ld.url = "github:nix-community/nix-ld";
    nil.url = "github:oxalica/nil";
    vscode-extensions.url = "github:nix-community/nix-vscode-extensions/";
    nix-index-database.url = "github:nix-community/nix-index-database";
    attic.url = "github:zhaofengli/attic";
    garage.url = "github:deuxfleurs-org/garage";

    nvim-github-theme = {
      url = "github:projekt0n/github-nvim-theme";
      flake = false;
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixcache.cy7.sh"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixcache.cy7.sh:DN3d1dt0wnXfTH03oVmTee4KgmdNdB0NY3SuzA8Fwx8="
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
              programs.typos.enable = true;
              programs.shellcheck.enable = true;

              programs.yamlfmt = {
                enable = true;
                settings.retain_line_breaks = true;
              };

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
