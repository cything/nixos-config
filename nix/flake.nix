{
  description = "cy's flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix, ... }@inputs:
  let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      ytnix = lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
