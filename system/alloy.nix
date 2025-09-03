{ config, lib, ... }:
let
  cfg = config.syslib.alloy;
in
{
  options.syslib.alloy = with lib; {
    enable = mkEnableOption "Grafana alloy metrics";
    apiKey = mkOption { type = types.str;  example = ''config.sops.placeholder."grafana/apikey"''; };
    user = mkOption { type = types.str;  example = ''config.sops.placeholder."grafana/user"''; };
    debug = mkEnableOption "alloy livedebugging";
    exposeWebUi = mkEnableOption "expose web ui with app proxy";
  };

  config = lib.mkIf cfg.enable {

    services.alloy = {
      enable = true;
      extraFlags = [
        "--disable-reporting"
        "--server.http.disable-support-bundle"
        "--server.http.ui-path-prefix=/alloy" # for app proxy
      ];
      configPath = "/etc/alloy";
    };

    # need static user to set ownership of secret config
    systemd.services.alloy.serviceConfig.DynamicUser = lib.mkForce false;
    users.users.alloy = {
      uid = 750;
      group = "alloy";
      home = "/var/lib/alloy";
      description = "alloy user";
    };
    users.groups.alloy.gid = 750;

    # alloy webui
    syslib.appproxy.apps."alloy" = lib.mkIf cfg.exposeWebUi {
      routeTo = "http://127.0.0.1:12345";
    };

    environment.etc."alloy/grafanacloud_export.alloy".source =
      config.sops.templates."grafanacloud_export.alloy".path;

    sops.templates."grafanacloud_export.alloy" = {
      owner = "alloy";
      content = ''
        prometheus.remote_write "grafanacloud" {
          endpoint {
            url = "https://prometheus-prod-24-prod-eu-west-2.grafana.net/api/prom/push"
            basic_auth {
              username = "${cfg.user}"
              password = "${cfg.apiKey}"
            }
          }
        }
      '';
    };

    # https://grafana.com/docs/alloy/latest/monitor/monitor-linux/
    environment.etc."alloy/unix_nodeinfo.alloy".text = ''

      prometheus.exporter.unix "integrations_node_exporter" {
        disable_collectors = ["ipvs", "btrfs", "infiniband", "xfs", "zfs"]
        filesystem {
          fs_types_exclude     = "^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|tmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$"
          mount_points_exclude = "^/(dev|proc|run/credentials/.+|sys|var/lib/docker/.+)($|/)"
          mount_timeout        = "5s"
        }
        netclass {
          ignored_devices = "^(veth.*|cali.*|[a-f0-9]{15})$"
        }
        netdev {
          device_exclude = "^(veth.*|cali.*|[a-f0-9]{15})$"
        }
      }

      discovery.relabel "integrations_node_exporter" {
        targets = prometheus.exporter.unix.integrations_node_exporter.targets
        rule {
          target_label = "instance"
          replacement  = constants.hostname
        }
        rule {
          target_label = "job"
          replacement = "integrations/node_exporter"
        }
      }

      prometheus.scrape "integrations_node_exporter" {
        targets    = discovery.relabel.integrations_node_exporter.output
        forward_to = [prometheus.relabel.integrations_node_exporter.receiver]
      }

      prometheus.relabel "integrations_node_exporter" {
        forward_to = [prometheus.remote_write.grafanacloud.receiver]
      }
    '';

    environment.etc."alloy/livedebugging.alloy" = lib.mkIf cfg.debug {
      text = ''
        livedebugging {
          enabled = true
        }
      '';
    };

  };
}
