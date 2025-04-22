{ config, lib, pkgs, ... }:
let
  cfg = config.homelib.hyprland;

  wallpaper = builtins.path {
    path = ./cody_foreman_the_rebuild_1920x1080.jpg;
    name = "wallpaper_fhd";
  };
  keybindings = import ./keybindings.nix { inherit config lib pkgs; };
in
{
  exec-once = [
    "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user start hyprland-session.target"
    "${pkgs.swaybg}/bin/swaybg --image ${wallpaper}"
    "${pkgs.waybar}/bin/waybar"
    "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
    "[workspace 2 silent] ${lib.getExe pkgs.firefox}"
  ];

  debug = {
    disable_logs = !cfg.debugMode;
    enable_stdout_logs = false;
  };

  env = [
    "HYPRCURSOR_THEME,phinger-cursors-light-hyprcursor"
    "HYPRCURSOR_SIZE,24"
  ];

  # TODO: move def out of here into host/profile config
  monitor = [ "eDP-1,1920x1080@60,0x0,1" "DP-1,1920x1080@60,1920x0,1" "DP-2,1920x1080@60,3840x0,1" ];

  input = {
    kb_layout = config.homelib.hyprland.keyMap;
    repeat_delay = 200;
    repeat_rate = 60;
  };
  
  # smart gaps (https://wiki.hyprland.org/Configuring/Workspace-Rules/#smart-gaps)
  workspace = [
    "w[tv1], gapsout:0, gapsin:0"
    "f[1], gapsout:0, gapsin:0"
  ];
  windowrulev2 = [
    "bordersize 0, floating:0, onworkspace:w[tv1]"
    "rounding 0, floating:0, onworkspace:w[tv1]"
    "bordersize 0, floating:0, onworkspace:f[1]"
    "rounding 0, floating:0, onworkspace:f[1]"
    # /smart gaps
  ];

  misc.force_default_wallpaper = 0;
} // keybindings
