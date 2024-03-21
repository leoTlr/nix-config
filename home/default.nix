{ pkgs, system, inputs, config, lib, commonSettings, ... }:

{
  imports = [
    ./fish.nix
    ./git
    ./hyprland
    ./firefox
    ./statix
    ./vscode
    ./gpg.nix
    ./sops.nix
    ./gammastep.nix
  ];

}