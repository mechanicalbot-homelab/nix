{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };
    wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      disko,
      deploy-rs,
      wsl,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkNixos =
        { name, modules }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ({
              nixpkgs.overlays = [
                (final: _prev: {
                  unstable = import inputs.nixpkgs-unstable {
                    system = final.system;
                    config.allowUnfree = true;
                  };
                })
              ];
            })
            ./hosts/${name}
          ]
          ++ modules;
        };
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      nixosConfigurations.dokploy = mkNixos {
        name = "dokploy";
        modules = [
          disko.nixosModules.disko
        ];
      };

      nixosConfigurations.desktop = mkNixos {
        name = "desktop";
        modules = [
          disko.nixosModules.disko
        ];
      };

      nixosConfigurations.wsl = mkNixos {
        name = "wsl";
        modules = [
          wsl.nixosModules.default
        ];
      };

      deploy =
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs { inherit system; };
          deployPkgs = import nixpkgs {
            inherit system;
            overlays = [
              deploy-rs.overlays.default
              (self: super: {
                deploy-rs = {
                  inherit (pkgs) deploy-rs;
                  lib = super.deploy-rs.lib;
                };
              })
            ];
          };
        in
        {
          remoteBuild = true;
          nodes = {
            dokploy = {
              hostname = "192.168.1.21";
              sshUser = "dev";
              profiles.system = {
                user = "root";
                path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.dokploy;
              };
            };
          };
        };
    };
}
