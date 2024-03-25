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
    };

    system = {
      isVmGuest = lib.mkOption {
        type = lib.types.bool;
        default = false;
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