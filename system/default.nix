{ pkgs, system, config, commonSettings, ... }:

{
  imports = [
    ./hyprland/hyprland.nix
    ./vmguest.nix
    ./fish.nix
    ./fonts.nix
  ];

}