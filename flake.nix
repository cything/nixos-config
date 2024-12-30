{
  description = "cy's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt.url = "github:numtide/treefmt-nix";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-borg.url = "github:cything/nixpkgs/borg"; # unmerged PR
    nixpkgs-btrbk.url = "github:cything/nixpkgs/btrbk"; # unmerged PR
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      treefmt,
      disko,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      inherit (self) outputs;

      systems = [ "x86_64-linux" ];
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});

      overridePkgsFromFlake =
        pkgs: flake: pkgNames:
        let
          pkgs' = import flake { inherit (pkgs) system config; };
          pkgNames' = builtins.map (lib.splitString ".") pkgNames;
          pkgVals = builtins.map (
            path:
            let
              package = lib.getAttrFromPath path pkgs';
            in
            lib.setAttrByPath path package
          ) pkgNames';
        in
        lib.foldl' lib.recursiveUpdate { } pkgVals;
      overlayPkgsFromFlake =
        flake: pkgNames: final: prev:
        overridePkgsFromFlake prev flake pkgNames;
      overlays = [
        (overlayPkgsFromFlake inputs.nixpkgs-small [
          "prometheus" # fails to build on unstable
        ])
      ];

      pkgsFor = lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system overlays;
          config = {
            allowUnfree = true;
          };
        }
      );

      treefmtEval = forEachSystem (
        pkgs:
        treefmt.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          programs.stylua.enable = true;
          programs.yamlfmt.enable = true;
          settings.formatter.yamlfmt.excludes = [ "secrets/*" ]; # sops does its own formatting
        }
      );
    in
    {
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      formatter = forEachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = forEachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      nixosConfigurations =
        let
          pkgs = pkgsFor.x86_64-linux;
        in
        {
          ytnix = lib.nixosSystem {
            specialArgs = { inherit inputs outputs; };
            modules = [
              {
                nixpkgs = { inherit pkgs; };
              }
              ./hosts/ytnix
              inputs.sops-nix.nixosModules.sops
            ];
          };

          chunk = lib.nixosSystem {
            specialArgs = { inherit inputs outputs; };
            modules = [
              {
                nixpkgs = { inherit pkgs; };
              }
              ./hosts/chunk
              inputs.sops-nix.nixosModules.sops
            ];
          };

          titan = lib.nixosSystem {
            specialArgs = { inherit inputs outputs; };
            modules = [
              {
                nixpkgs = { inherit pkgs; };
              }
              ./hosts/titan
              disko.nixosModules.disko
              inputs.sops-nix.nixosModules.sops
            ];
          };
        };

      homeConfigurations = {
        "yt@ytnix" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./home/yt/ytnix.nix
          ];
        };

        "yt@chunk" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./home/yt/chunk.nix
          ];
        };
      };
    };
}
