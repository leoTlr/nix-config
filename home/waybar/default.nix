{ pkgs, config, lib, ... }:
let
  waybarConfig = import ./config.nix { inherit pkgs; };
  waybarCss = import ./styling.nix {};
in 
{

  options.waybar.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use waybar";
  };

  config = lib.mkIf config.waybar.enable {
    programs.waybar = {
      enable = true;
      settings.mainBar = waybarConfig;
      style = waybarCss;
    };
  };
  
}