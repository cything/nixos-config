{
  description = "cy's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote/master";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    conduwuit.url = "github:girlbossceo/conduwuit";
    conduwuit.inputs.nixpkgs.follows = "nixpkgs";
    lix-module.url = "git+https://git.lix.systems/lix-project/nixos-module?ref=release-2.92";
    lix-module.inputs.nixpkgs.follows = "nixpkgs";
    nix-ld.url = "github:nix-community/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
    nil.url = "github:oxalica/nil";
    nil.inputs.nixpkgs.follows = "nixpkgs";
    vscode-extensions.url = "github:nix-community/nix-vscode-extensions/";
    vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    garage.url = "github:deuxfleurs-org/garage";
    garage.inputs.nixpkgs.follows = "nixpkgs";
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
      ...
    }@inputs:
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
                inputs.nix-index-database.hmModules.nix-index
              ];
            };

            "yt@chunk" = lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = { inherit inputs; };
              modules = [
                ./home/yt/chunk.nix
              ];
            };
          };
      };
}
