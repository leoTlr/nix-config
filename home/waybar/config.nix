{ pkgs }:
let
  modules = import ./modules.nix { inherit pkgs; };
in
{
  mod = "dock";
  layer = "top";
  gtk-layer-shell = true;
  height = 14;
  position = "top";

  modules-left = [
    "custom/menu"
    "hyprland/workspaces"
  ];

  modules-right = [
    "network"
    "custom/waybar-systemd-indicator"
    "bluetooth"
    "pulseaudio#microphone"
    "backlight"
    "battery"
    "tray"
    "clock"
  ];

} // modules