{meta, ...}: {
  imports = [
    ../modules/telemetry/node-exporter.nix
  ];

  users.users.flokkq = {
    name = "flokkq";
    initialPassword = "ciscodisco";
    extraGroups = ["networkmanager" "wheel" "docker"];
    group = "users";

    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDC6IaWNRHLcGbwq1MuwVABawDBt6zeIxgXFCCB2NMUU flokkq@cerulean-statistician"
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  networking.hostName = meta.name;

  virtualisation.docker.enable = true;

  nixpkgs = {
    hostPlatform = meta.system.arch;
    config.allowUnsupportedSystem = true;
  };

  infra.telemetry.nodeExporter.enable = true;

  time.timeZone = "Europe/Vienna";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_AT.UTF-8";
      LC_IDENTIFICATION = "de_AT.UTF-8";
      LC_MEASUREMENT = "de_AT.UTF-8";
      LC_MONETARY = "de_AT.UTF-8";
      LC_NAME = "de_AT.UTF-8";
      LC_NUMERIC = "de_AT.UTF-8";
      LC_PAPER = "de_AT.UTF-8";
      LC_TELEPHONE = "de_AT.UTF-8";
      LC_TIME = "de_AT.UTF-8";
    };
  };

  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [22]; # SSH

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = ["@wheel"];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  system.stateVersion = "24.11";
}
