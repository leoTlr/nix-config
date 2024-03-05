{ config, pkgs, commonSettings }:
let
  wallpaper = builtins.path {
    path = ./cody_foreman_the_rebuild_1920x1080.jpg;
    name = "wallpaper_fhd";
  };
  keybindings = import ./keybindings.nix { inherit config pkgs; };
in
{
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

  master = {
    no_gaps_when_only = 1;
  };

  misc.force_default_wallpaper = 0;
} // keybindings