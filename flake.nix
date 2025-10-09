{
  description = "Top Level nixOS flake for my home-server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    ...
  } @ inputs: let
    inherit (self) outputs;

    homeLib = import ./lib/default.nix {};

    hosts = [
      {
        name = "template-rpi";
        system = {
          type = "rpi-5";
          arch = "aarch64-linux";
        };
      }
      {
        name = "template-server";
        system = {
          type = "server";
          arch = "x86_64-linux";
        };
      }
    ];

    forAllSystems = fn: nixpkgs.lib.genAttrs homeLib.systems (systems: fn {pkgs = import nixpkgs {inherit systems;};});
  in {
    formatter = forAllSystems ({pkgs}: pkgs.alejandra);

    nixosConfigurations = builtins.listToAttrs (map (host: {
        name = host.name;
        value = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            meta = {
              hostname = host.name;
              system = host.system;
            };
          };

          system = host.system.arch;

          modules = [
            disko.nixosModules.disko

            ./hosts/${host.system.type}/configuration.nix
            ./hosts/${host.system.type}/disko-config.nix

            ./hosts/${host.system.type}/${host.name}/hardware-configuration.nix
          ];
        };
      })
      hosts);
  };
}
