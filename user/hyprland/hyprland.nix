{lib, config, pkgs, commonSettings, ... }:
let
  wallpaper = builtins.path {
    path = ./cody_foreman_the_rebuild_1920x1080.jpg;
    name = "wallpaper_fhd";
  };
in
{ 

  imports = [
    ../gtk
    ../waybar
    ../kitty
  ];

  options.wm.modkey = lib.mkOption {
    type = lib.types.str;
    default = "SUPER";
    example = "ALT";
  };

  config = {

    home.packages = with pkgs; [
      kitty
      networkmanagerapplet
      swaybg
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

      settings = {
        exec-once = [
          "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          #"dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          #"systemctl --user start hyprland-session.target"
          "${pkgs.swaybg}/bin/swaybg --image ${wallpaper}"
          "${pkgs.waybar}/bin/waybar"
        ];

        monitor = [ ",1920x1080@60,0x0,1" ];

        input = {
          kb_layout = commonSettings.localization.keymap;
          repeat_delay = 200;
          repeat_rate = 60;
        };

        "$modkey" = config.wm.modkey;

        master = {
          no_gaps_when_only = 1;
        };

        # bind modifiers
        # l -> locked, aka. works also when an input inhibitor (e.g. a lockscreen) is active.
        # r -> release, will trigger on release of a key.
        # e -> repeat, will repeat when held.
        # n -> non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.
        # m -> mouse, see below
        # t -> transparent, cannot be shadowed by other binds.
        # i -> ignore mods, will ignore modifiers.
        bind = [
          "$modkey, return, exec, kitty"
          "$modkey, Q, killactive,"
          "$modkey SHIFT, M, exit,"
          "$modkey SHIFT, F, togglefloating,"
          "$modkey, F, fullscreen,"
          "$modkey, D, exec, ${pkgs.wofi}/bin/wofi --show drun"

          "$modkey, left, movefocus, l"
          "$modkey, right, movefocus, r"
          "$modkey, up, movefocus, u"
          "$modkey, down, movefocus, d"

          "$modkey SHIFT, left, movewindow, l"
          "$modkey SHIFT, right, movewindow, r"
          "$modkey SHIFT, up, movewindow, u"
          "$modkey SHIFT, down, movewindow, d"

          # Scroll through existing workspaces with modkey + scroll
          "bind = $modkey, mouse_down, workspace, e+1"
          "bind = $modkey, mouse_up, workspace, e-1"
        ];

        misc.force_default_wallpaper = 0;

      };

    };

  };
}
