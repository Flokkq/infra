{
  meta,
  hostsByName,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    ../../../modules/telemetry/grafana.nix
    ../../../modules/telemetry/prometheus.nix
  ];

  infra.telemetry.prometheus = {
    enable = true;
    nodeExporterTargets = [
      "${hostsByName.template-rpi.deployment.targetHost}:9100"
      "${hostsByName.template-server.deployment.targetHost}:9100"
    ];
  };

  infra.telemetry.grafana = {
    enable = true;
    domain = meta.deployment.targetHost;
    prometheusUrl = "http://localhost:9090";
  };
}
