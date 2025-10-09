# Server configuration
# <https://github.com/nix-community/nixos-generators?tab=readme-ov-file#format-specific-notes>
_: {
  boot = {
    kernelParams = ["console=tty0"]; # Log to display instead of serial console

    # GRUB timeout
    loader.timeout = 5;
  };

  # Allow recovery by setting a root password
  users.mutableUsers = true;
}
