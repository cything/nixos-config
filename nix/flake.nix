{
  description = "cy's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    master.url = "github:NixOS/nixpkgs/2ab79c44f98391b6ee2edfb11f4c7a57ce1404b5";
  };

  outputs = {
    self,
    nixpkgs,
    sops-nix,
    home-manager,
    ...
    }@inputs: let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      inherit (self) outputs;
    in
    {
      packages = import ./pkgs nixpkgs.legacyPackages.${system};
      formatter =  nixpkgs.legacyPackages.${system}.nixpkgs-fmt;

      nixosConfigurations = {
        ytnix = lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./nixos/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
      };

      homeConfigurations = {
        "yt@ytnix" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./home-manager/home.nix
          ];
        };
      };
    };
}
