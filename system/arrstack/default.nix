{ config, cfglib, lib, ... }:
let
  cfg = config.syslib.arrstack;
  # arrUser = "jack";
in
{
  options.syslib.arrstack = with lib; {
    enable = mkEnableOption "arrstack";
    domain = mkOption {
      type = types.str;
      default = "arr.home.arpa";
      # services accessible at custom paths
      # i.e. arr.home.arpa/traefik
    };
  };

  imports = cfglib.nixModulesIn ./.;

  config = lib.mkIf cfg.enable {

    # users = {
    #   users.${arrUser} = {
    #     isSystemUser = true;
    #     createHome = true;
    #   };
    #   groups.pirates.members = [ arrUser ];
    # };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.traefik = {
      enable = true;
      staticConfigOptions = {
        log.level = "INFO";
        accessLog = {};
        # log.level = "DEBUG";
        # accessLog.addInternals = true;
        entryPoints = {
          web = {
            address = ":80";
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
            };
          };
          websecure = {
            address = ":443";
            http.tls.options = "default";
          };
        };
        api = {
          dashboard = true;
          insecure = false;
          basePath = "/traefik";
        };
      };
      dynamicConfigOptions = {
        http.routers.dashboard = {
          rule = "Host(`${cfg.domain}`) && PathPrefix(`/traefik`)";
          service = "api@internal";
          entrypoints = [ "websecure" ];
          tls.options = "default";
        };
        tls = {
          options.default = {
            minVersion = "VersionTLS13";
            sniStrict = true;
          };
          stores.default.defaultCertificate = {
            # TODO: move into sops
            certFile = "/var/lib/traefik/arr.home.arpa.crt";
            keyFile = "/var/lib/traefik/arr.home.arpa.key.nopass";
          };
          certificates = [{
            # TODO: move into sops
            certFile = "/var/lib/traefik/arr.home.arpa.crt";
            keyFile = "/var/lib/traefik/arr.home.arpa.key.nopass";
          }];
        };
      };
    };
    
  };
}
