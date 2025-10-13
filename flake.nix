{
  description = "Top Level nixOS flake for my home-server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
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
    sops-nix,
    ...
  }: let
    lib = nixpkgs.lib;

    homeLib = import ./lib/default.nix {};

    hosts = [
      {
        name = "template-rpi";
        system = {
          type = "rpi-5";
          arch = "aarch64-linux";
        };
        deployment = {
          targetHost = "10.0.0.52";
          targetPort = 22;
          targetUser = "template-pi";
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

    shouldBuildOnTarget = host: host.system.arch != builtins.currentSystem;

    mkColmenaHosts = hosts:
      lib.listToAttrs (map (host: {
          name = host.name;
          value = {
            imports = [
              {_module.args.meta = host;}

              disko.nixosModules.disko

              ./hosts/base-configuration.nix
              ./hosts/${host.system.type}/base-configuration.nix
              ./hosts/${host.system.type}/disko-config.nix
              ./hosts/${host.system.type}/${host.name}/configuration.nix
            ];

            deployment = lib.mkMerge [
              host.deployment
              {
                sshOptions = [
                  "-i"
                  "~/.ssh/colmena"
                  "-o"
                  "StrictHostKeyChecking=accept-new"
                ];
              }
              (lib.mkIf (shouldBuildOnTarget host) {buildOnTarget = true;})
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

          specialArgs = {
            inherit self nixpkgs disko colmena sops-nix;
            hostsByName = homeLib.hostsToAttrSet hosts;
            hosts = hosts;
          };
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
