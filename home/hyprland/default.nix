{ lib, config, pkgs, commonSettings, ... }:
let
  cfg = config.homelib.hyprland;
  hyprlandSettings = import ./settings.nix { 
    inherit config pkgs commonSettings;
  };
in
{ 

  imports = [
    ../gtk
    ../waybar
    ../kitty
  ];

  options.homelib.hyprland = {

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Use hyprland wm";
    };

    modkey = lib.mkOption {
      type = lib.types.str;
      default = "SUPER";
      example = "ALT";
    };

  };

  config = lib.mkIf cfg.enable {

    homelib.kitty.enable = true;
    homelib.gtk.theming.enable = true;
    homelib.waybar.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      xwayland.enable = true;
      systemd.enable = true; # hyprland-session.target

      settings = hyprlandSettings;
    };

  };
}
