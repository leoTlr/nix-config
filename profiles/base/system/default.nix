{ config, lib, pkgs, ... }:
let
  cfg = config.profiles.base;
in
{
  imports = [
    ../../../system
  ];

  options.profiles.base = import ./interface.nix { inherit lib; };

  config = import ./settings.nix { inherit config pkgs; };

}