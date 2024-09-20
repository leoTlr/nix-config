{ config, commonSettings, sysConfig, homeConfig, ... }:
let
  homeDir = "/home/${commonSettings.user.name}";
in
{

  imports = [
    ../../profiles/desktop/home
  ];

  profiles.base = {
    home = {
      userName = commonSettings.user.name;
      dir = homeDir;
      stateVersion = "23.11";
      configName = homeConfig;
    };
    system.configName = sysConfig;
    gitInfo = {
      name = "leoTlr";
      email = "ltlr+github@posteo.de";
      signKey = "17F0A6278F9E22B4A846DAEAE0CF76180D567EDF";
  };

    inherit (commonSettings) localization;
  };

  profiles.desktop.enable = true;

}
