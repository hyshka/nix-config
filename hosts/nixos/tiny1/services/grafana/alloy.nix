{ config, ... }:
{
  services.alloy.enable = true;

  environment.etc."alloy/config.alloy".text = ''
    loki.relabel "journal" {
      forward_to = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
      rule {
        source_labels = ["__journal__systemd_user_unit"]
        target_label  = "user_unit"
      }
      rule {
        source_labels = ["__journal__boot_id"]
        target_label  = "boot_id"
      }
      rule {
        source_labels = ["__journal__priority_keyword"]
        target_label  = "level"
      }
    }

    loki.source.journal "read" {
      max_age        = "12h"
      format_as_json = true
      relabel_rules  = loki.relabel.journal.rules
      forward_to     = [loki.write.default.receiver]
      labels         = {
        job  = "systemd-journal",
        host = "${config.networking.hostName}",
      }
    }

    loki.write "default" {
      endpoint {
        url = "http://localhost:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push"
      }
    }
  '';
}
