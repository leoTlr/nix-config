{ config, lib, ... }:
let
  cfg = config.syslib.aistack;
in
{
  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate =
      pkg: builtins.elem (lib.getName pkg) [
        "open-webui"
      ];

    services.open-webui = {
      enable = true;
      host = "127.0.0.1";
      openFirewall = false;
      port = cfg.ports.open-webui;
      environment = {
        # WEBUI_URL = "https://tower.home.arpa/";
        # ENABLE_PERSISTENT_CONFIG = "False";
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        ENABLE_VERSION_UPDATE_CHECK = "False";
      };
    };
  };
}
