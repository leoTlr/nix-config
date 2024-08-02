{ config, commonSettings, configName, ... }:
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
      inherit configName;
    };
    gitInfo = {
      name = "leoTlr";
      email = "ltlr+github@posteo.de";
  };

    inherit (commonSettings) localization;
  };

  profiles.desktop.enable = true;

}
