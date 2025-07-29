{ config, lib, pkgs,... }:
let
  cfg = config.syslib.arrstack.sonarr;
  acfg = config.syslib.arrstack;
in
{
  options.syslib.arrstack.sonarr = with lib; {
    enable = mkEnableOption "sonarr";

    port = mkOption {
      type = types.port;
      default = 8989;
    };

    libraryDir = mkOption {
      type = types.str;
      description = ''path to series library'';
    };

    apiKey = mkOption { type = types.str;  example = ''config.sops.placeholder."sonarr/apikey''; };
  };

  config = lib.mkIf cfg.enable {

    services.traefik.dynamicConfigOptions.http = {
      services.sonarr.loadBalancer.servers = [{
        url = "http://127.0.0.1:${builtins.toString cfg.port}";
      }];
      routers.sonarr = {
        rule = "Host(`${acfg.domain}`) && PathPrefix(`/sonarr`)";
        service = "sonarr";
        entrypoints = [ "websecure" ];
        tls.options = "default";
        middlewares = [ "authelia@file" ];
      };
    };

    sops.templates."sonarr-config.xml" = {
      owner = "sonarr";
      restartUnits = [ "sonarr.service" ];
      content = import ./arr-config.xml {
        inherit lib;
        arrSettings = {
          inherit (cfg) port apiKey;
          name = "Sonarr";
          host = "127.0.0.1";
          urlBase = "/sonarr";
          logLevel = "info";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "L+ /var/lib/sonarr/config.xml 0600 sonarr sonarr - ${config.sops.templates."sonarr-config.xml".path}"
    ];

    users.users.sonarr = {
      uid = 702;
      group = "sonarr";
      home = "/var/lib/sonarr";
      description = "sonarr user";
    };

    users.groups.sonarr.gid = 702;

    systemd.services.sonarr = {
      description = "sonarr server";
      wantedBy = [ "multi-user.target" ];
      wants = acfg.waitOnMountUnits;
      after = [ "network.target" ] ++ acfg.waitOnMountUnits;
      serviceConfig = {
        Type = "simple";
        User = "sonarr";
        Group = "sonarr";
        StateDirectory = "sonarr";
        WorkingDirectory = "~";
        ReadWritePaths = cfg.libraryDir; # exception from ProtectSystem = strict

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

        ExecStart = "${lib.getExe pkgs.sonarr} -nobrowser -data='/var/lib/sonarr'";
      };
    };

  };
}
