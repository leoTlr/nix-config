{ config, commonSettings, ... }:
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
    };
    system.isVmGuest = true;
    gitInfo = {
      name = "leoTlr";
      email = "ltlr+github@posteo.de";
  };

    inherit (commonSettings) localization;
  };

  profiles.desktop.enable = true;

}
