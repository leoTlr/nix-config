{ config, pkgs, lib, ... }:
let
  cfg = config.gammastep;
  bindUnits = 
    [ "sops-nix.service" ] ++ (
      if cfg.systemdBindTarget != null 
      then [ cfg.systemdBindTarget ] 
      else []
    );
in
{
  options.gammastep = {

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use gammastep to reduce blue light during the night";
    };
    
    systemdBindTarget = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Bind to specific systemd target";
      example = "hyprland-session.target";
    };

    temperature = {
      day = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 5300;
        description = "Day color temperature in K"; 
      };
      night = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 2700;
        description = "Night color temperature in K";
      };
    };
    
    location = {
      latPath = lib.mkOption {
        type = lib.types.path;
        description = "Path to file containing latitude";
      };
      lonPath = lib.mkOption {
        type = lib.types.path;
        description = "Path to file containing longitude";
      };
    };
  
  };

  config = lib.mkIf cfg.enable {

    home.packages = [ pkgs.gammastep ];

    # own systemd service instead of home.services.gammastep because:
    # - able to bind to custom systemd target
    # - can use sops + LoadCredential to not expose location
    systemd.user.services.gammastep = {

      Unit = {
        After = bindUnits;
      };
      Install = {
        WantedBy = bindUnits;
      };
      
      Service = {

        ExecStart = ''
          ${pkgs.bash}/bin/bash -c "\
          ${pkgs.gammastep}/bin/gammastep \
            -l $(${pkgs.systemd}/bin/systemd-creds cat lat):$(${pkgs.systemd}/bin/systemd-creds cat lon) \
            -t ${toString cfg.temperature.day}:${toString cfg.temperature.night}"
        '';
        
        LoadCredential = [
          "lat:${toString cfg.location.latPath}"
          "lon:${toString cfg.location.lonPath}"
        ];

        RestartSec = 3;
        Restart = "on-failure";

      };

    };
    
  };
}