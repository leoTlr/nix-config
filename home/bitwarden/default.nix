{ config, lib, pkgs, ...}:
let
  cfg = config.homelib.bitwarden;
in
{
  options.homelib.bitwarden= {
    enable = lib.mkEnableOption "bitwarden";
    enableGui = lib.mkEnableOption "bitwarden-desktop";
  };

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.bitwarden-cli
    ] ++ lib.optionals cfg.enableGui [
      pkgs.bitwarden-desktop
    ];

  };
}
