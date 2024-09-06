{ lib, config, pkgs, commonSettings, ... }:
let
  cfg = config.homelib.hyprland;
  hyprlandSettings = import ./settings.nix {
    inherit config lib pkgs commonSettings;
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

    screenLock = lib.mkEnableOption "screenLock";

  };

  config = lib.mkIf cfg.enable {

    homelib = {
      kitty.enable = true;
      gtk.theming.enable = true;
      waybar.enable = true;
      mako.enable = true;
      screenlock = lib.mkIf cfg.screenLock {
        enable = true;
        systemdBindTarget = "hyprland-session.target";
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      xwayland.enable = true;
      systemd.enable = true; # hyprland-session.target

      settings = hyprlandSettings;
    };

  };
}
