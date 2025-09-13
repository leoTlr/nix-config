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
    downloadDir = mkOption {
      type = types.str;
      description = ''where the download client places downloaded series'';
    };

    apiKey = mkOption { type = types.str;  example = ''config.sops.placeholder."sonarr/apikey''; };
  };

  config = lib.mkIf cfg.enable {

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
      unitConfig.AssertPathExists = config.sops.templates."sonarr-config.xml".path;
      serviceConfig = {
        ReadWritePaths = [ cfg.libraryDir cfg.downloadDir ]; # exception from ProtectSystem = strict
        ExecStart = "${lib.getExe pkgs.sonarr} -nobrowser -data='/var/lib/sonarr'";
      };
    };

  };
}
