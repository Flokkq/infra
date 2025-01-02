{pkgs, ...}: {
  time.timeZone = "Europe/Vienna";
  users.users.root = {
    initialPassword = "root";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.machine = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    initialPassword = "ciscodisco";
  };

  networking = {
    hostName = "machine";
  };
  environment.systemPackages = with pkgs; [
    git
    neovim
  ];
  services.openssh = {
    enable = true;
  };
  system.stateVersion = "25.05";
}
