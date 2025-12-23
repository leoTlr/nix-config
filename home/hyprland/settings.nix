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

  # dont define directive if empty to let hyprland decide what to do in this case
  monitor = lib.mkIf
    ((builtins.length cfg.monitors) > 0)
    cfg.monitors;

  input = {
    kb_layout = config.homelib.hyprland.keyMap;
    repeat_delay = 200;
    repeat_rate = 60;
  };

  workspace = [
    "special:scratchpad, gapsout:200, gapsin:100, shadow:true, border:true, on-created-empty: kitty"

    # smart gaps (https://wiki.hyprland.org/Configuring/Workspace-Rules/#smart-gaps)
    "w[tv1]s[false], gapsout:0, gapsin:0"
    "f[1]s[false], gapsout:0, gapsin:0"
  ];
  windowrulev2 = [
    "bordersize 0, floating:0, onworkspace:w[tv1]s[false]"
    "rounding 0, floating:0, onworkspace:w[tv1]s[false]"
    "bordersize 0, floating:0, onworkspace:f[1]s[false]"
    "rounding 0, floating:0, onworkspace:f[1]s[false]"
    # /smart gaps
  ];

  general = {
    gaps_in = 5;
    gaps_out = 10;
  };

  misc.force_default_wallpaper = 0;

} // keybindings
