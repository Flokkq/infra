{...}: {
  imports = [];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."pi" = {
    isNormalUser = true;
    hashedPassword = "$6$11223344$S6Gf4bnR14eaichyb4EL05gh7Y9QnvM3dnjvksVz7AW7L4O48FrNNmyOC2bYegaG28D93FbXx6vBDtZtHZvS4/";
    extraGroups = ["networkmanager" "wheel" "docker"];
  };
  security.sudo.wheelNeedsPassword = true;

  system.stateVersion = "24.11";
}
