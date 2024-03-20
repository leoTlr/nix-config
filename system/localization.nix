{ config, lib, ... }:
let
  baseprofile = config.profiles.base.localization;
  cfg = config.syslib.localization;
in
{
  options.syslib.localization.enable = lib.mkEnableOption "localization";

  config = lib.mkIf cfg.enable {
    time.timeZone = baseprofile.timezone;
    i18n.defaultLocale = baseprofile.locale;
    console.keyMap = baseprofile.keymap;
  };
}