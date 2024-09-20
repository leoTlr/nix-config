{ config, lib, pkgs, ... }:
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
      };
      dir = lib.mkOption {
        type = lib.types.path;
      };
      stateVersion = lib.mkOption {
        type = lib.types.str;
      };
      configName = lib.mkOption {
        type = lib.types.str;
        description = "Name of the homeConfiguration used";
      };
    };

    gitInfo = {
      name = lib.mkOption {
        type = lib.types.str;
        default = cfg.userName;
      };
      email = lib.mkOption {
        type = lib.types.str;
      };
      signKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
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
      };
      timezone = lib.mkOption {
        type = lib.types.str;
      };
      keymap = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  config = import ./settings.nix { inherit config pkgs; };

}