{ config, lib, pkgs, ... }:
let
  cfg = config.profiles.base;
in
{
  imports = [
    ../../../system/fish.nix
    ../../../system/fonts.nix
    ../../../system/vmguest.nix
  ];

  options.profiles.base = import ./interface.nix { inherit lib; };

  config = import ./settings.nix { inherit config pkgs; };

}