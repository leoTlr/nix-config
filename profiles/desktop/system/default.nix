{ config, lib, ... }:
let
  cfg = config.profiles.desktop;
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
  };

  config = {
    profiles.base.enable = true;

    sound.enable = true;
    syslib.hyprland.enable = true;
  };

}