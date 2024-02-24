{ pkgs, system, inputs, config, lib, commonSettings, ... }:

{
  imports = [
    ./fish.nix
    ./git.nix
    ./hyprland/hyprland.nix
    ./firefox.nix
  ];

}