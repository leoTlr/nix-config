{ config, lib, pkgs,... }:
let
  cfg = config.syslib.arrstack.sabnzbd;
  acfg = config.syslib.arrstack;
in
{
  options.syslib.arrstack.sabnzbd = with lib; {
    enable = mkEnableOption "sabnzbd";
    port = mkOption {
      type = types.port;
      default = 5000; 
    };
  };

  config = lib.mkIf cfg.enable {

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "unrar" # dep from sabnzbd pkg
    ];

    services.traefik.dynamicConfigOptions.http = {
      services.sabnzbd.loadBalancer.servers = [{
        url = "http://127.0.0.1:${builtins.toString cfg.port}?skip_wizard=1";
      }];
      routers.sabnzbd = {
        rule = "Host(`${acfg.domain}`) && PathPrefix(`/sabnzbd`)";
        service = "sabnzbd";
        entrypoints = [ "websecure" ];
        tls.options = "default";
      };
    };

    sops.templates."sabnzbd.ini" = {
      owner = "sabnzbd";
      content = import ./sabnzbd.ini {
        inherit lib;
        sabSettings = {
          host = "127.0.0.1";
          port = cfg.port;
          urlBase = "/sabnzbd";
          hostWhitelist = "${acfg.domain},";
          apiKey = config.sops.placeholder."sabnzbd/apikey";
          nzbKey = config.sops.placeholder."sabnzbd/nzbkey";
        };
        usenetProviders = [
          {
            host = config.sops.placeholder."sabnzbd/servers/A/host";
            port = config.sops.placeholder."sabnzbd/servers/A/port";
            connections = config.sops.placeholder."sabnzbd/servers/A/connections";
            priority = config.sops.placeholder."sabnzbd/servers/A/priority";
            username = config.sops.placeholder."sabnzbd/servers/A/username";
            password = config.sops.placeholder."sabnzbd/servers/A/password";
          }
          {
            host = config.sops.placeholder."sabnzbd/servers/B/host";
            port = config.sops.placeholder."sabnzbd/servers/B/port";
            connections = config.sops.placeholder."sabnzbd/servers/B/connections";
            priority = config.sops.placeholder."sabnzbd/servers/B/priority";
            username = config.sops.placeholder."sabnzbd/servers/B/username";
            password = config.sops.placeholder."sabnzbd/servers/B/password";
          }
        ];
      };
    };

    users.users.sabnzbd = {
      uid = 777;
      group = "sabnzbd";
      home = "/var/lib/sabnzbd";
      description = "sabnzbd user";
    };

    users.groups.sabnzbd.gid = 777;

    systemd.services.sabnzbd = {
      description = "sabnzbd server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        # Type = "forking";
        # GuessMainPID = "no";
        User = "sabnzbd";
        Group = "sabnzbd";
        StateDirectory = "sabnzbd";
        WorkingDirectory = "~";

        # workaround because sabnzbd needs to write to the conf file at runtime
        # changes made in the ui are reset on every start
        ExecStartPre = lib.getExe (pkgs.writeShellApplication {
          name = "sabnzbdConfigCreate";
          text = ''
            echo "Recreating sabnzbd config from template..."
            mv sabnzbd.ini "sabnzbd.ini.$(date +%Y-%m-%d-%H-%M-%S)"
            cp ${config.sops.templates."sabnzbd.ini".path} sabnzbd.ini
            chown sabnzbd:sabnzbd sabnzbd.ini
            chmod 600 sabnzbd.ini
          '';
        });        
        ExecStopPost = lib.getExe (pkgs.writeShellApplication {
          name = "sabnzbdConfigDiff";
          runtimeInputs = [ pkgs.diffutils ];
          text = ''
            if ! changes="$(diff ${config.sops.templates."sabnzbd.ini".path} sabnzbd.ini)"; then
              echo "WARN: sabnzbd changed config during runtime. These changes will be lost on next start:"
              echo "$changes"
            else
              echo "INFO: No config changes during runtime"
            fi;
          '';
        });
        ExecStart = "${lib.getExe pkgs.sabnzbd} --config-file ./sabnzbd.ini";
      };
    };

  };
}
