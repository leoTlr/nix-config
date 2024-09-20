{ userConfig, sysConfig, homeConfig, ... }:
let
  homeDir = "/home/${userConfig.userName}";
in
{

  imports = [
    ../../profiles/desktop/home
  ];

  profiles.base = {
    home = {
      userName = userConfig.userName;
      dir = homeDir;
      stateVersion = "23.11";
      configName = homeConfig;
    };
    system.configName = sysConfig;
    gitInfo = {
      name = "leoTlr";
      email = "ltlr@posteo.de";
      signKey = "17F0A6278F9E22B4A846DAEAE0CF76180D567EDF";
  };

    inherit (userConfig) localization;
  };

  profiles.desktop.enable = true;

}
