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
    # it's not really "master"
    master.url = "github:NixOS/nixpkgs/2ab79c44f98391b6ee2edfb11f4c7a57ce1404b5";
    # this has the caddy module with environmentFile option
    testpkgs.url = "github:NixOS/nixpkgs/248081c4729259c3add830d502779c5d04cbe074";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    inherit (self) outputs;

    systems = ["x86_64-linux"];
    forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs systems (
      system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        }
    );
  in {
    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});
    formatter = forEachSystem (pkgs: pkgs.alejandra);
    devShells = forEachSystem (pkgs: import ./shells {inherit pkgs;});
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;
    overlays = import ./overlays {inherit inputs outputs;};

    nixosConfigurations = let
      pkgs = pkgsFor.x86_64-linux;
    in {
      ytnix = lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          {
            nixpkgs = {inherit pkgs;};
          }
          ./hosts/ytnix
          inputs.sops-nix.nixosModules.sops
        ];
      };

      chunk = lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          {
            nixpkgs = {inherit pkgs;};
          }
          ./hosts/chunk
          inputs.sops-nix.nixosModules.sops
        ];
      };
    };

    homeConfigurations = {
      "yt@ytnix" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home/yt/ytnix.nix
        ];
      };
    };
  };
}
