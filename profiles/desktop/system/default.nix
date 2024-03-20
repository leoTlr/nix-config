{ config, lib, ... }:
let
  cfg = config.profiles.desktop;
in
{
  imports = [
    ../../../profiles/base/system
    ../../../system/hyprland/hyprland.nix
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
    hyprland.enable = true;
  };

}