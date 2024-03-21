{ pkgs, config, lib, ... }:
let
  nixlint = pkgs.writeShellScriptBin "nixlint" ''
    ${pkgs.statix}/bin/statix check -c ${./config.toml} $1
  '';
in
{
   options.statix.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install statix linter for nix";
    };
    
    config.home.packages = lib.mkIf config.statix.enable [ nixlint pkgs.statix ];
}