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

    configLock = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Lock access to config pages in webui.
        This prevents changes though webui but you also cant check what is configured.
        Changes made during runtime will be discarded on next restart anyway.
      '';
    };

    outDir = mkOption {
      type = types.str;
      description = ''sabnzbd output for completed downloads'';
    };

    apiKey = mkOption { type = types.str;  example = ''config.sops.placeholder."sabnzbd/apikey''; };
    nzbKey = mkOption { type = types.str;  example = ''config.sops.placeholder."sabnzbd/nzbkey''; };

    usenetProviders = mkOption {
      type = types.listOf (types.submodule {
        options = {
          # int values can also be str to be able to pass sops-nix placeholders for secrets
          host = mkOption { type = types.str; };
          port = mkOption { type = types.oneOf [ types.port types.str ]; };
          connections = mkOption { type = types.oneOf [ types.ints.positive types.str ]; };
          priority = mkOption { type = types.oneOf [ (types.ints.between 0 100) types.str ]; };
          username = mkOption { type = types.str; };
          password = mkOption { type = types.str; };
        };
      });
      default = [];
      example = ''
        [{
          host = config.sops.placeholder."sabnzbd/servers/A/host";
          host = config.sops.placeholder."sabnzbd/servers/A/port";
          host = config.sops.placeholder."sabnzbd/servers/A/connections";
          host = config.sops.placeholder."sabnzbd/servers/A/username";
          host = config.sops.placeholder."sabnzbd/servers/A/password";
          priority = 0;
        }]
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "unrar" # dep from sabnzbd pkg
    ];

    sops.templates."sabnzbd.ini" = {
      owner = "sabnzbd";
      restartUnits = [ "sabnzbd.service" ];
      content = import ./sabnzbd.ini {
        inherit lib;
        inherit (cfg) usenetProviders;
        sabSettings = {
          inherit (cfg) port apiKey nzbKey configLock outDir;
          host = "127.0.0.1";
          urlBase = "/sabnzbd";
          hostWhitelist = "${acfg.domain},";
        };
      };
    };

    users.users.sabnzbd = {
      uid = 700;
      group = "sabnzbd";
      home = "/var/lib/sabnzbd";
      description = "sabnzbd user";
    };

    users.groups.sabnzbd.gid = 700;

    systemd.services.sabnzbd = {
      description = "sabnzbd server";
      wantedBy = [ "multi-user.target" ];
      wants = acfg.waitOnMountUnits;
      after = [ "network.target" ] ++ acfg.waitOnMountUnits;
      serviceConfig = {
        Type = "simple";
        # Type = "forking";
        # GuessMainPID = "no";
        User = "sabnzbd";
        Group = "sabnzbd";
        StateDirectory = "sabnzbd";
        WorkingDirectory = "~";
        ReadWritePaths = cfg.outDir; # exception from ProtectSystem = strict

        # hardening
        ProtectSystem = "strict";
        ProtectHome = "yes";
        PrivateDevices = "yes";
        PrivateTmp = "yes";
        PrivateIPC = "yes";
        PrivatePIDs = "yes";
        ProtectHostname = "yes";
        ProtectClock = "yes";
        ProtectKernelTunables = "yes";
        ProtectKernelModules = "yes";
        ProtectKernelLogs = "yes";
        ProtectControlGroups = "yes";
        LockPersonality = "yes";

        # workaround because sabnzbd needs to write to the conf file at runtime
        # changes made in the ui are reset on every start
        ExecStartPre = lib.getExe (pkgs.writeShellApplication {
          name = "sabnzbdConfigCreate";
          text = ''
            echo "Recreating sabnzbd config from template..."
            mv sabnzbd.ini "sabnzbd.ini.$(date +%Y-%m-%d-%H-%M-%S)" || true
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
