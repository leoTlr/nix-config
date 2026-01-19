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

  # dont define directive if empty to let hyprland decide what to do in this case
  monitor = lib.mkIf
    ((builtins.length cfg.monitors) > 0)
    cfg.monitors;

  input = {
    kb_layout = config.homelib.hyprland.keyMap;
    repeat_delay = 200;
    repeat_rate = 60;
    touchpad.scroll_factor = 2.0;
  };

  # workaround for https://github.com/hyprwm/Hyprland/discussions/12788
  # can also be set per monitor, see https://wiki.hypr.land/Configuring/Monitors/#extra-args
  render.cm_sdr_eotf = lib.mkIf
    (lib.versionAtLeast pkgs.hyprland.version "0.53.0")
    2
  ;

  workspace = [
    "special:scratchpad, gapsout:200, gapsin:100, shadow:true, border:false, on-created-empty: ${lib.getExe pkgs.kitty}"
    "special:top, gapsout:80, gapsin:40, shadow:true, border:false, on-created-empty: ${lib.getExe pkgs.kitty} ${lib.getExe pkgs.btop}"

    # smart gaps (https://wiki.hyprland.org/Configuring/Workspace-Rules/#smart-gaps)
    "w[tv1]s[false], gapsout:0, gapsin:0"
    "f[1]s[false], gapsout:0, gapsin:0"
  ];
  windowrule = lib.mkIf (lib.versionAtLeast pkgs.hyprland.version "0.53.0") [
    "border_size 0, match:float 0, match:workspace w[tv1]s[false]"
    "rounding 0, match:float 0, match:workspace w[tv1]s[false]"
    "border_size 0, match:float 0, match:workspace f[1]s[false]"
    "rounding 0, match:float 0, match:workspace f[1]s[false]"
    # /smart gaps
  ];
  windowrulev2 = lib.mkIf (lib.versionOlder pkgs.hyprland.version "0.53.0") [
    "bordersize 0, floating:0, onworkspace:w[tv1]s[false]"
    "rounding 0, floating:0, onworkspace:w[tv1]s[false]"
    "bordersize 0, floating:0, onworkspace:f[1]s[false]"
    "rounding 0, floating:0, onworkspace:f[1]s[false]"
  ];

  general = {
    gaps_in = 3;
    gaps_out = 6;
  };

  decoration = {
    rounding = 0;
    dim_inactive = false;
    dim_strength = 0.1;
    shadow.enabled = true;
  };

  # https://wiki.hypr.land/Configuring/Animations/
  animations = {
    enabled = true;
    animation = [
      "specialWorkspace, 1, 3, default, slidefadevert top"
    ];
  };

  misc.force_default_wallpaper = 0;

} // keybindings
