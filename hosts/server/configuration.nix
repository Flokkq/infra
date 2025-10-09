_: {
  imports = [
    ../../nixos
  ];

  users.users.server = {
    name = "server";
    initialPassword = "ciscodisco";
    extraGroups = ["networkmanager" "wheel" "docker"];
    group = "users";

    isNormalUser = true;
  };
  security.sudo.wheelNeedsPassword = true;

  system.stateVersion = "24.11";
}
