{ config, lib, pkgs,... }:
let
  cfg = config.syslib.arrstack.prowlarr;
in
{
  options.syslib.arrstack.prowlarr = with lib; {
    enable = mkEnableOption "prowlarr";

    port = mkOption {
      type = types.port;
      default = 9696;
    };

    apiKey = mkOption { type = types.str;  example = ''config.sops.placeholder."prowlarr/apikey''; };
  };

  config = lib.mkIf cfg.enable {

    sops.templates."prowlarr-config.xml" = {
      owner = "prowlarr";
      restartUnits = [ "prowlarr.service" ];
      content = import ./arr-config.xml {
        inherit lib;
        arrSettings = {
          inherit (cfg) port apiKey;
          name = "Prowlarr";
          host = "127.0.0.1";
          urlBase = "/prowlarr";
          logLevel = "info";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "L+ /var/lib/prowlarr/config.xml 0600 prowlarr prowlarr - ${config.sops.templates."prowlarr-config.xml".path}"
    ];

    users.users.prowlarr = {
      uid = 703;
      group = "prowlarr";
      home = "/var/lib/prowlarr";
      description = "prowlarr user";
    };

    users.groups.prowlarr.gid = 703;

    systemd.services.prowlarr = {
      description = "prowlarr server";
      unitConfig.AssertPathExists =
        config.sops.templates."prowlarr-config.xml".path;
      serviceConfig.ExecStart = "${lib.getExe pkgs.prowlarr} -nobrowser -data='/var/lib/prowlarr'";
    };

  };
}
