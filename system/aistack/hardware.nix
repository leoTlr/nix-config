{ pkgs, lib, config, ... }:
let
  cfg = config.syslib.aistack;
in
{
  config = lib.mkIf cfg.enable {
    hardware.graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
    nixpkgs.config.rocmSupport = true;
    hardware.amdgpu.opencl.enable = true;
    services.xserver.videoDrivers = [ "radeon" ];
  };
}
