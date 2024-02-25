{ pkgs, system, inputs, config, lib, ... }:

{
  imports = [
    ./fish.nix
    ./git.nix
    ./hyprland/hyprland.nix
  ];

}