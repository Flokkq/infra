{
  config,
  lib,
  ...
}: let
  cfg = config.infra.telemetry.nodeExporter;
in {
  options.infra.telemetry.nodeExporter = {
    enable = lib.mkEnableOption "Prometheus node exporter";

    port = lib.mkOption {
      type = lib.types.port;
      default = 9100;
    };

    enabledCollectors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "systemd"
        "textfile"
        "filesystem"
        "loadavg"
        "meminfo"
        "netdev"
        "stat"
      ];
      description = "List of enabled collectors";
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      port = cfg.port;
      enabledCollectors = cfg.enabledCollectors;
    };

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
