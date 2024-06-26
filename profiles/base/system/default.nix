{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.profiles.base;
in
{
  imports = [
    ../../../system
    inputs.sops-nix.nixosModules.default
  ];

  options.profiles.base = import ./interface.nix { inherit lib; };

  config = import ./settings.nix { inherit config pkgs; };

}