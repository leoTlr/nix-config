{ config, lib, ... }:
let
  cfg = config.syslib.arrstack.nzbget;
  acfg = config.syslib.arrstack;
in
{
  options.syslib.arrstack.nzbget = with lib; {
    enable = mkEnableOption "nzbget" ;
    port = mkOption {
      type = types.port;
      default = 6789; # default ControlPort
    };
  };

  config = lib.mkIf cfg.enable {

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "unrar" # dep from nzbget pkg
    ];

    # networking.firewall.allowedTCPPorts = [
    #   6789 # ControlPort
    #   6791 # SecurePort
    # ];

    services.traefik.dynamicConfigOptions.http = {
      services.nzbget.loadBalancer.servers = [{
        url = "http://127.0.0.1:${builtins.toString cfg.port}";
      }];
      routers.nzbget = {
        rule = "Host(`${acfg.domain}`) && PathPrefix(`/nzbget`)";
        service = "nzbget";
        entrypoints = [ "websecure" ];
        tls.options = "default";
      };
    };

    services.nzbget = {
      enable = true;
      settings = {
        #MainDir = cfg.dataDir + "/nzbget";
        ControlIP = "127.0.0.1";
        ControlPort = builtins.toString cfg.port;

        # for now no auth. plan: sops or mTls or sso
        ControlUsername = "";
        ControlPassword = "";
      };
    };

  };
}
