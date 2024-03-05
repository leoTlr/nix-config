{ pkgs, system, inputs, config, lib, commonSettings, ... }:

{
  imports = [
    ./fish.nix
    ./git
    ./hyprland/hyprland.nix
    ./firefox
    ./statix
    ./vscode
  ];

}