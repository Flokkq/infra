{
  description = "Top Level nixOS flake for my home-server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    _nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

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

    systems = [
      "aarch64-linux"
      "x84_64-linux"
    ];

    hostSystems = [
      "rpi-5"
      "linux"
    ];

    hosts = [
      {
        name = "template";
        system = "rpi-5";
      }
    ];

    # Validate if the hostsSystem is correctly configured
    _ =
      map (
        host: assert builtins.elem host.system hostSystems; host
      )
      hosts;

    forAllSystems = fn: nixpkgs.lib.genAttrs systems (systems: fn {pkgs = import nixpkgs {inherit systems;};});
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

          system =
            if builtins.elem "rpi-5" hostSystems
            then "aarch64-linux"
            else "x86_64-linux";

          modules = [
            disko.nixosModules.disko

            ./hosts/${host.system}/configuration.nix
            ./hosts/${host.system}/disko-config.nix

            # ./hosts/${host.system}/${host.name}/hardware-configuration.nix
          ];
        };
      })
      hosts);
  };
}
