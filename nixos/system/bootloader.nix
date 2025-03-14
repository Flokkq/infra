# Bootloader Configuration
#- https://wiki.nixos.org/wiki/Bootloader
_: {
  boot.loader = {
    systemd-boot = {
      enable = true;
      # https://wiki.nixos.org/wiki/Bootloader#Limiting_amount_of_entries_with_grub
      configurationLimit = 12;

      # Allow editing the kernel command-line before boot
      # enabled by default for backwards compatibility
      # Recommended to set this to false,
      # as it allows gaining root access by passing
      # init=/bin/sh as a kernel parameter
      editor = false;

      # Set the highest resolution available
      consoleMode = "max";

      memtest86.enable = false;

      rebootForBitlocker = false; # Experimental BitLocker support
    };

    efi.canTouchEfiVariables = true;
    grub.useOSProber = true;
  };
}
