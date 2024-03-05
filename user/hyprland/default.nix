{ lib, config, pkgs, commonSettings, ... }:
let
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

  options.hyprland = {

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

  config = lib.mkIf config.hyprland.enable {

    home.packages = with pkgs; [
      networkmanagerapplet
      mako
    ];

    kitty.enable = true;
    gtk.theming.enable = true;
    waybar.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      xwayland.enable = true;
      systemd.enable = true; # hyprland-session.target

      settings = hyprlandSettings;
    };

  };
}
