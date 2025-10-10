{...}: {
  imports = [
    ./hardware-configuration.nix

    ../../../modules/telemetry/grafana.nix
    ../../../modules/telemetry/node-exporter.nix
  ];
}
