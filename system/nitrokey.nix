{ config, lib, pkgs, ...}:
let
  udevRulesPatched = pkgs.nitrokey-udev-rules.overrideAttrs (prev: {
    version = "1.1.0";
    buildInputs = [ pkgs.ruff pkgs.pyright ];
    src = pkgs.fetchFromGitHub {
      owner = "Nitrokey";
      repo = "nitrokey-udev-rules";
      rev = "v1.1.0";
      hash = "sha256-LKpd6O9suAc2+FFgpuyTClEgL/JiZiokH3DV8P3C7Aw=";
  };});
in
{
  options.syslib.nitrokey.enable = lib.mkEnableOption "nitrokey";

  config = lib.mkIf config.syslib.nitrokey.enable {
    services.udev.packages = [ udevRulesPatched ];
    environment.systemPackages = [ pkgs.pynitrokey ];
  };
}
