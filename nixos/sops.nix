{sops-nix, ...}: let
  home = builtins.getEnv "HOME";
in {
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    age.keyFile = "${home}/sops-nix/key.txt";
    age.generateKey = true;
  };
}
