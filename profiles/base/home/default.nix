{ config, lib, pkgs, userConfig, ... }:
let
  cfg = config.profiles.base;
in
{
  imports = [
    ../../../home
  ];

  options.profiles.base = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use base home config for system";
    };

    home = {
      userName = lib.mkOption {
        type = lib.types.str;
        default = userConfig.userName;
      };
      dir = lib.mkOption {
        type = lib.types.path;
        default = "/home/${cfg.home.userName}";
      };
      stateVersion = lib.mkOption {
        type = lib.types.str;
      };
      configName = lib.mkOption {
        type = lib.types.str;
        description = "Name of the homeConfiguration used";
      };
    };

    system = {
      isVmGuest = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      configName = lib.mkOption {
        type = lib.types.str;
        description = "Name of the system configuration used";
      };
    };

    localization = {
      locale = lib.mkOption {
        type = lib.types.str;
        default = userConfig.localization.locale;
      };
      timezone = lib.mkOption {
        type = lib.types.str;
        default = userConfig.localization.timezone;
      };
      keymap = lib.mkOption {
        type = lib.types.str;
        default = userConfig.localization.keymap;
      };
    };
  };

  config = import ./settings.nix { inherit lib config pkgs userConfig; };

}