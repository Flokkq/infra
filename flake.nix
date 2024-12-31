{
  description = "Bramble Test 5";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
  };

  outputs = {
    self,
    nixpkgs,
    raspberry-pi-nix,
  }: let
    inherit (nixpkgs.lib) nixosSystem;
    basic-config = {
      pkgs,
      lib,
      ...
    }: {
      # bcm2711 for rpi 3, 3+, 4, zero 2 w
      # bcm2712 for rpi 5
      # See the docs at:
      # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
      raspberry-pi-nix.board = "bcm2712";
      time.timeZone = "America/Chicago";
      users.users.root = {
        initialPassword = "root";
      };
      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.gak = {
        isNormalUser = true;
        extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
        initialPassword = "gak";
      };

      networking = {
        hostName = "bramble-test-5";
      };
      environment.systemPackages = with pkgs; [
        emacs
        git
        wget
      ];
      services.openssh = {
        enable = true;
      };
      system.stateVersion = "24.05";
    };
  in {
    nixosConfigurations = {
      bramble-test-5 = nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          crossSystem = {config = "aarch64-linux";};
        };
        modules = [
          raspberry-pi-nix.nixosModules.raspberry-pi
          raspberry-pi-nix.nixosModules.sd-image
          basic-config
        ];
      };
    };
  };
}
