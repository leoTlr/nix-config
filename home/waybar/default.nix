{ pkgs, config, lib, inputs, ... }:
let
  cfg = config.homelib.waybar;
  waybarConfig = import ./config.nix { inherit pkgs; };
  waybarCss = import ./styling.nix { inherit config; };
in
{
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  options.homelib.waybar.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use waybar";
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      settings.mainBar = waybarConfig;
      style = waybarCss;
    };
  };

}