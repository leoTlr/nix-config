{ config, pkgs }:

{ 
  "$modkey" = config.hyprland.modkey;

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
    "$modkey, F,            fullscreen,"
    "$modkey, D,            exec, ${pkgs.wofi}/bin/wofi --show drun"

    "$modkey, left,         movefocus, l"
    "$modkey, right,        movefocus, r"
    "$modkey, up,           movefocus, u"
    "$modkey, down,         movefocus, d"

    "$modkey SHIFT, left,   movewindow, l"
    "$modkey SHIFT, right,  movewindow, r"
    "$modkey SHIFT, up,     movewindow, u"
    "$modkey SHIFT, down,   movewindow, d"

    # Scroll through existing workspaces with modkey + scroll
    "$modkey, mouse_down,   workspace, e+1"
    "$modkey, mouse_up,     workspace, e-1"
  ];
}