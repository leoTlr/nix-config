{ userConfig, ... }:
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
    };

    system.isVmGuest = true;

    inherit (userConfig) localization;
  };

  profiles.desktop.enable = true;

}
