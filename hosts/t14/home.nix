{ sysConfig, homeConfig, ... }:

{

  imports = [
    ../../profiles/desktop/home
  ];

  profiles.base = {
    home = {
      stateVersion = "23.11";
      configName = homeConfig;
    };
    system.configName = sysConfig;
  };

  profiles.desktop.enable = true;

}
