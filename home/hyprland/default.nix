{ lib, config, pkgs, userConfig, ... }:
let
  cfg = config.homelib.hyprland;
  hyprlandSettings = import ./settings.nix {
    inherit config lib pkgs userConfig;
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
      dunst.enable = true;
      screenlock = lib.mkIf cfg.screenLock {
        enable = true;
        systemdBindTarget = "hyprland-session.target";
      };
    };

    # volume/brightness notification
    # alternative: https://github.com/heyjuvi/avizo
    services.swayosd = {
      enable = true;
      topMargin = 0.9;
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
