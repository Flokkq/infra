{lib, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.generic-extlinux-compatible.enable = true;
  hardware.deviceTree.enable = true;

  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.initrd.reduceModules = false;
}
