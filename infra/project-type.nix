{lib}: {
  options.project = {
    repo = lib.mkOption {
      type = lib.types.str;
      description = "The Git repository for the project";
      example = "github:Flokkq/smd-store";
    };

    docker_image = lib.mkOption {
      type = lib.types.str;
      description = "The Docker image to use for deployment";
      example = "flokkq/global-connect-api:latest";
    };

    config = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Custom configuration for the project (optional).";
    };

    type = lib.mkOption {
      type = lib.types.enum ["pi" "server"];
      description = "The deployment target type (e.g., 'pi' or 'server').";
      example = "pi";
    };
  };
}
