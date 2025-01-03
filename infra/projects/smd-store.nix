{lib, ...}: let
  projectType = import ../project-type.nix {inherit lib;};
in {
  project =
    projectType.options.project
    // {
      repo = "github:Flokkq/smd-store";
      docker_image = "flokkq/smd-store:latest";
      config = {pkgs, ...}: {
        environment.variables.SMD_STORE_PORT = "8080";
      };
      type = "pi";
    };
}
