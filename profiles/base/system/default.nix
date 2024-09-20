{ config, lib, pkgs, userConfig, ... }:

{
  imports = [
    ../../../system
  ];

  options.profiles.base = import ./interface.nix { inherit lib userConfig; };

  config = import ./settings.nix { inherit config pkgs; };

}