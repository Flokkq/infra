{
  description = "Top Level nixOS flake for my home-server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    colmena,
    ...
  }: let
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {system = builtins.currentSystem;};

    homeLib = import ./lib/default.nix {};

    hosts = [
      {
        name = "template-rpi";
        system = {
          type = "rpi-5";
          arch = "aarch64-linux";
        };
        deployment = {
          targetHost = "192.168.190.2";
          targetPort = 1234;
          targetUser = "pi";
        };
      }
      {
        name = "template-server";
        system = {
          type = "server";
          arch = "x86_64-linux";
        };
        deployment = {
          targetHost = "192.168.190.3";
          targetPort = 1234;
          targetUser = "server";
        };
      }
    ];

    forAllSystems = f:
      nixpkgs.lib.genAttrs homeLib.systems
      (system: f {pkgs = import nixpkgs {inherit system;};});

    mkColmenaHosts = hosts:
      lib.listToAttrs (map (host: {
          name = host.name;
          value = _: {
            nixpkgs.hostPlatform = host.system.arch;
            networking.hostName = host.name;

            imports = [
              disko.nixosModules.disko
              ./hosts/${host.system.type}/base-configuration.nix
              ./hosts/${host.system.type}/disko-config.nix
              ./hosts/${host.system.type}/${host.name}/configuration.nix
            ];

            deployment = lib.mkMerge [
              host.deployment
              (lib.mkIf (host.system.arch == "aarch64-linux" || pkgs.stdenv.isDarwin) {buildOnTarget = true;})
            ];
          };
        })
        hosts);
  in {
    formatter = forAllSystems ({pkgs}: pkgs.alejandra);

    colmenaHive = colmena.lib.makeHive (
      {
        meta = {
          nixpkgs = import nixpkgs {
            system = builtins.currentSystem;
            overlays = [];
          };
          specialArgs = {inherit self nixpkgs disko colmena;};
        };
      }
      // mkColmenaHosts hosts
    );

    # the colmena flake input is more recent then the `colmena` package in nixpkgs
    # because of that we use the binary that comes with the flake input
    # nix run .#colmena
    packages = lib.genAttrs homeLib.systems (system: {
      colmena = colmena.packages.${system}.colmena;
    });

    apps = lib.genAttrs homeLib.systems (system: {
      colmena = {
        type = "app";
        program = lib.getExe (colmena.packages.${system}.colmena);
      };
    });
  };
}
