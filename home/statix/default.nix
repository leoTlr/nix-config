{ pkgs, config, lib, ... }:
let
  cfg = config.homelib.statix;
  nixlint = pkgs.writeShellScriptBin "nixlint" ''
    ${pkgs.statix}/bin/statix check -c ${./config.toml} $1
  '';
in
{
   options.homelib.statix.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install statix linter for nix";
    };
    
    config.home.packages = lib.mkIf cfg.enable [ nixlint pkgs.statix ];
}