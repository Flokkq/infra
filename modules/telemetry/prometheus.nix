{
  config,
  lib,
  ...
}: let
  cfg = config.infra.telemetry.prometheus;
in {
  options.infra.telemetry.prometheus = {
    enable = lib.mkEnableOption "Prometheus monitoring server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 9090;
    };

    scrapeConfigs = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "Additional scrape configurations";
    };

    nodeExporterTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of node exporter targets (host:port)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;

      port = cfg.port;

      scrapeConfigs =
        [
          # Self-monitoring
          {
            job_name = "prometheus";
            static_configs = [
              {
                targets = ["localhost:${toString cfg.port}"];
              }
            ];
          }

          # Node exporters - auto-discover infra hosts
          {
            job_name = "node-exporter";
            static_configs = [
              {
                targets = cfg.nodeExporterTargets;
              }
            ];
          }
        ]
        ++ cfg.scrapeConfigs;
    };

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
