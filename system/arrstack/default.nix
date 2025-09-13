{ config, cfglib, lib, ... }:
let
  cfg = config.syslib.arrstack;

  arrUnitNames = [
    "sabnzbd"
    "radarr"
    "sonarr"
    "prowlarr"
  ];

  mkArrUnit = name: {
    unitConfig.PartOf = "arrstack.target";
    after = [ "traefik.service" ] ++ cfg.waitOnMountUnits;
    wants = [ "traefik.service" ] ++ cfg.waitOnMountUnits;
    serviceConfig = {
      Type = "simple";
      User = name;
      Group = name;
      StateDirectory = name;
      WorkingDirectory = "~";
      Slice = lib.mkIf config.syslib.resourceControl.enable "workload.slice";

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
    };
  };
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

    systemd.targets."arrstack" = {
      requires = builtins.map
        (name: if cfg.${name}.enable then "${name}.service" else "")
        arrUnitNames;
      after = [ "traefik.service" ] ++ cfg.waitOnMountUnits;
      wants = [ "traefik.service" ] ++ cfg.waitOnMountUnits;
      wantedBy = [ "default.target" ];
    };

    systemd.services = lib.genAttrs arrUnitNames
      (name: lib.mkIf cfg.${name}.enable (mkArrUnit name));
  };
}
