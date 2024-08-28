{ config, lib, ...}:
# https://nixos.wiki/wiki/Bluetooth
{
  options.syslib.bluetooth.enable = lib.mkEnableOption "bluetooth";

  config = lib.mkIf config.syslib.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # provides: blueman-manager, blueman-applet
    services.blueman.enable = true;
  };
}