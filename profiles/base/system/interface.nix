{ lib, ... }:

{
  enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Use base config for system";
  };

  system = {
    hostName = lib.mkOption {
      type = lib.types.str;
    };
    mainUser = {
      name = lib.mkOption {
        type = lib.types.str;
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
      description = "The first version of NixOS installed on this particular machine";
      # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
    };
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

}