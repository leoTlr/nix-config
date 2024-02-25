{ pkgs, system, config, commonSettings, ... }:

{
  imports = [
    ./hyprland/hyprland.nix
    ./vmguest.nix
    ./fish.nix
  ];

  config.nix.settings.experimental-features = [ "nix-command" "flakes" ];
}