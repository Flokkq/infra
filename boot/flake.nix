{
  description = "A NixOS flake for building bootable images for home servers and Raspberry Pi devices";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    raspberry-pi-nix = {
      url = "github:nix-community/raspberry-pi-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    raspberry-pi-nix,
  }: let
    inherit (nixpkgs.lib) nixosSystem;
  in {
    nixosConfigurations = {
      pi = nixosSystem {
        system = "aarch64-linux";
        modules = [
          raspberry-pi-nix.nixosModules.raspberry-pi
          raspberry-pi-nix.nixosModules.sd-image

          ./basic-config.nix
          ./pi.nix
        ];
      };
    };

    };
  };
}
