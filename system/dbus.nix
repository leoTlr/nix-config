{ lib, pkgs, ... }:

{
  options.syslib.dbus.enable = lib.mkEnableOption "dbus";

  config = {
    services.dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };

    programs.dconf = {
      enable = true;
    };

    services.logind.extraConfig = ''
      IdleAction=lock
    '';

  };
}