{ config, lib, ... }:
let
  cfg = config.profiles.desktop;
  basecfg = config.profiles.base;
in
{
  imports = [
    ../../../profiles/base/system
  ];

  options.profiles.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Treat host as desktop";
    };
    bluetooth.enable = lib.mkEnableOption "bluetooth";
  };

  config = {
    profiles.base.enable = true;

    syslib = {
      hyprland = {
        enable = true;
        inherit (basecfg.system) isVmGuest;
        user = basecfg.system.mainUser.name;
      };
      bluetooth.enable = cfg.bluetooth.enable;
    };
  };

}