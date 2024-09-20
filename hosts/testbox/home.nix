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
    system = {
      configName = sysConfig;
      isVmGuest = true;
    };
  };

  profiles.desktop.enable = true;

}
