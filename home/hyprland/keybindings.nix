{ config, pkgs }:
let
  cfg = config.homelib.hyprland;


  vol = ammount: "${pkgs.swayosd}/bin/swayosd-client --output-volume ${ammount} --max-volume 100";
  vol_up = vol "+5";
  vol_down = vol "-5";
  vol_mute = vol "mute-toggle";

  brightness = ammount: "${pkgs.swayosd}/bin/swayosd-client --brightness ${ammount}";
  brightness_up = brightness "+3";
  brightness_down = brightness "-3";

in
{
  "$modkey" = cfg.modkey;

  # bind modifiers
  # l -> locked, aka. works also when an input inhibitor (e.g. a lockscreen) is active.
  # r -> release, will trigger on release of a key.
  # e -> repeat, will repeat when held.
  # n -> non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.
  # m -> mouse, see below
  # t -> transparent, cannot be shadowed by other binds.
  # i -> ignore mods, will ignore modifiers.
  bind = [
    "$modkey, return,       exec, kitty"
    "$modkey, Q,            killactive,"
    "$modkey SHIFT, M,      exit,"
    "$modkey SHIFT, F,      togglefloating,"
    "$modkey, E,            togglegroup,"
    "$modkey, F,            fullscreen,"
    "$modkey, R,            exec, ${pkgs.hyprland}/bin/hyprctl reload"
    "$modkey, D,            exec, ${pkgs.wofi}/bin/wofi --show drun"
    "$modkey, L,            exec, ${config.homelib.swaylock.lock.command}"

    "$modkey, left,         movefocus, l"
    "$modkey, right,        movefocus, r"
    "$modkey, up,           movefocus, u"
    "$modkey, down,         movefocus, d"

    # move single windows in a workspace or between workspaces
    "$modkey SHIFT, left,   movewindoworgroup, l"
    "$modkey SHIFT, right,  movewindoworgroup, r"
    "$modkey SHIFT, up,     movewindoworgroup, u"
    "$modkey SHIFT, down,   movewindoworgroup, d"

    # move a complete workspace with all its windows
    "$modkey CTRL, left,   movecurrentworkspacetomonitor, l"
    "$modkey CTRL, right,  movecurrentworkspacetomonitor, r"
    "$modkey CTRL, up,     movecurrentworkspacetomonitor, u"
    "$modkey CTRL, down,   movecurrentworkspacetomonitor, d"

    # Switch to workspace using number row
    "$modkey, 1,            workspace, 1"
    "$modkey, 2,            workspace, 2"
    "$modkey, 3,            workspace, 3"
    "$modkey, 4,            workspace, 4"
    "$modkey, 5,            workspace, 5"
    "$modkey, 6,            workspace, 6"
    "$modkey, 7,            workspace, 7"
    "$modkey, 8,            workspace, 8"
    "$modkey, 9,            workspace, 9"
    "$modkey, 0,            workspace, 10"

    # Scroll through existing workspaces with modkey + scroll
    "$modkey, mouse_down,   workspace, e+1"
    "$modkey, mouse_up,     workspace, e-1"

    # Move window to workspace using number row
    "$modkey SHIFT, 1,     movetoworkspace, 1"
    "$modkey SHIFT, 2,     movetoworkspace, 2"
    "$modkey SHIFT, 3,     movetoworkspace, 3"
    "$modkey SHIFT, 4,     movetoworkspace, 4"
    "$modkey SHIFT, 5,     movetoworkspace, 5"
    "$modkey SHIFT, 6,     movetoworkspace, 6"
    "$modkey SHIFT, 7,     movetoworkspace, 7"
    "$modkey SHIFT, 8,     movetoworkspace, 8"
    "$modkey SHIFT, 9,     movetoworkspace, 9"
    "$modkey SHIFT, 0,     movetoworkspace, 10"
  ];

  bindel = [
    ",XF86AudioRaiseVolume, exec, ${vol_up}"
    ",XF86AudioLowerVolume, exec, ${vol_down}"
  ];

  binde = [
    ",XF86MonBrightnessDown,    exec, ${brightness_down}"
    ",XF86MonBrightnessUp,      exec,  ${brightness_up}"
  ];

  bindl = [
    ",XF86AudioMute, exec, ${vol_mute}"
  ];

}
