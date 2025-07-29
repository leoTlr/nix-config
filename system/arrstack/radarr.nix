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

    apiKey = mkOption { type = types.str;  example = ''config.sops.placeholder."radarr/apikey''; };
  };

  config = lib.mkIf cfg.enable {

    services.traefik.dynamicConfigOptions.http = {
      services.radarr.loadBalancer.servers = [{
        url = "http://127.0.0.1:${builtins.toString cfg.port}";
      }];
      routers.radarr = {
        rule = "Host(`${acfg.domain}`) && PathPrefix(`/radarr`)";
        service = "radarr";
        entrypoints = [ "websecure" ];
        tls.options = "default";
        middlewares = [ "authelia@file" ];
      };
    };

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

        # workaround because radarr stores most config in a db
        #
        # TODO: maybe do via api (call in ExecStartPost). Idk how the categories come into the db
        #       maybe just patch url and apikey in db
        #       maybe just use prowlarr and recyclarr/configarr
        # ExecStartPre = lib.getExe (pkgs.writeShellApplication {
        #   name = "radarrConfigEnsure";
        #   runtimeInputs = [ pkgs.sqlite pkgs.diffutils ];
        #   text = ''
        #     echo "Ensuring radarr indexer config..."
        #     if changes="$(diff <(sqlite3 ./radarr.db 'PRAGMA table_info(Indexers)') ${dbIndexerTableStructure})"; then
        #       echo "ERROR: radarr db Indexers table structure changed:"
        #       echo "$changes"
        #       exit 1
        #     fi
        #
        #     sqlite3 ./radarr.db 'SQL STATEMENT to create Indexers from config';
        #   '';
        # });

        ExecStart = "${lib.getExe pkgs.radarr} -nobrowser -data='/var/lib/radarr'";
      };
    };

  };
}
