{ config, lib, pkgs,... }:
let
  cfg = config.syslib.arrstack.radarr;
  acfg = config.syslib.arrstack;
in
{
  options.syslib.arrstack.radarr = with lib; {
    enable = mkEnableOption "radarr";

    port = mkOption {
      type = types.port;
      default = 7878;
    };

    libraryDir = mkOption {
      type = types.str;
      description = ''path to movie library'';
    };
    downloadDir = mkOption {
      type = types.str;
      description = ''where the download client places downloaded movies'';
    };

    apiKey = mkOption { type = types.str;  example = ''config.sops.placeholder."radarr/apikey''; };
  };

  config = lib.mkIf cfg.enable {

    sops.templates."radarr-config.xml" = {
      owner = "radarr";
      restartUnits = [ "radarr.service" ];
      content = import ./arr-config.xml {
        inherit lib;
        arrSettings = {
          inherit (cfg) port apiKey;
          name = "Radarr";
          host = "127.0.0.1";
          urlBase = "/radarr";
          logLevel = "info";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "L+ /var/lib/radarr/config.xml 0600 radarr radarr - ${config.sops.templates."radarr-config.xml".path}"
    ];

    users.users.radarr = {
      uid = 701;
      group = "radarr";
      home = "/var/lib/radarr";
      description = "radarr user";
    };

    users.groups.radarr.gid = 701;

    systemd.services.radarr = {
      description = "radarr server";
      wantedBy = [ "multi-user.target" ];
      wants = acfg.waitOnMountUnits;
      after = [ "network.target" ] ++ acfg.waitOnMountUnits;
      serviceConfig = {
        Type = "simple";
        User = "radarr";
        Group = "radarr";
        StateDirectory = "radarr";
        WorkingDirectory = "~";
        ReadWritePaths = [ cfg.libraryDir cfg.downloadDir ]; # exception from ProtectSystem = strict

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

        ExecStart = "${lib.getExe pkgs.radarr} -nobrowser -data='/var/lib/radarr'";
      };
    };

  };
}
