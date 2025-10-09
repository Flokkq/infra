{
  description = "A NixOS flake for building bootable images for home servers and Raspberry Pi devices";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    raspberry-pi-nix = {
      url = "github:nix-community/raspberry-pi-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    raspberry-pi-nix,
    nixos-generators,
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
          ./rpi5.nix
        ];
      };
    };

    packages.x86_64-linux.diskImage = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      modules = [
        ./basic-config.nix
        ./server.nix
      ];

      format = "raw-efi";
    };
  };
}
