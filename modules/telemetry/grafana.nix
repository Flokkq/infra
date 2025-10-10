{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.infra.telemetry.grafana;
in {
  options.infra.telemetry.grafana = {
    enable = lib.mkEnableOption "Grafana monitoring dashboard";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port for Grafana web interface";
    };

    prometheusUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:9090";
      description = "URL of Prometheus server";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      description = "Domain name for Grafana";
    };
  };

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_port = cfg.port;
          http_addr = "0.0.0.0";
          domain = cfg.domain;
          root_url = "http://${cfg.domain}:${toString cfg.port}/";
        };

        security = {
          admin_user = "admin";
          admin_password = "admin";
        };

        "auth.anonymous" = {
          enabled = true;
          org_role = "Viewer";
        };
      };

      provision = {
        enable = true;

        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = cfg.prometheusUrl;
            isDefault = true;
          }
        ];

        dashboards.settings.providers = [
          {
            name = "default";
            options.path = "/var/lib/grafana/dashboards";
          }
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [cfg.port];

    environment.etc."grafana/dashboards/node-exporter.json".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/rfmoz/grafana-dashboards/master/prometheus/node-exporter-full.json";
      sha256 = "sha256-fqNEHu0nD7WSBAB7PSfYoMXBnRaS05eByqqLXS5PgIQ=";
    };

    # Create directory for dashboards and copy our dashboard
    systemd.tmpfiles.rules = [
      "d /var/lib/grafana/dashboards 755 grafana grafana"
      "C /var/lib/grafana/dashboards/node-exporter.json 644 grafana grafana - /etc/grafana/dashboards/node-exporter.json"
    ];
  };
}
