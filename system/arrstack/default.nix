{ config, cfglib, lib, ... }:
let
  cfg = config.syslib.arrstack;
in
{
  options.syslib.arrstack = with lib; {
    enable = mkEnableOption "arrstack";
    domain = mkOption { type = types.str; };
    waitOnMountUnits = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        arr systemd units wait for given units
      '';
    };
  };

  imports = cfglib.nixModulesIn ./.;

  config = lib.mkIf cfg.enable {

    syslib.appproxy = {
      enable = true;
      fqdn = cfg.domain;
      apps = {
        sabnzbd.routeTo = lib.mkIf cfg.sabnzbd.enable
          "http://localhost:${builtins.toString cfg.sabnzbd.port}";
        radarr.routeTo = lib.mkIf cfg.radarr.enable
          "http://localhost:${builtins.toString cfg.radarr.port}";
        sonarr.routeTo = lib.mkIf cfg.sonarr.enable
          "http://localhost:${builtins.toString cfg.sonarr.port}";
        prowlarr.routeTo = lib.mkIf cfg.prowlarr.enable
          "http://localhost:${builtins.toString cfg.prowlarr.port}";
      };
    };

    systemd.services = lib.mkIf config.syslib.resourceControl.enable {
      sabnzbd.serviceConfig.Slice = "workload.slice";
      radarr.serviceConfig.Slice = "workload.slice";
      prowlarr.serviceConfig.Slice = "workload.slice";
      sonarr.serviceConfig.Slice = "workload.slice";
    };

  };
}
