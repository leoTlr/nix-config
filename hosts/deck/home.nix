{ ... }:

{

  profiles.base = {
    enable = true;
    stateVersion = "25.05";
    sysConfigName = null;
  };

  homelib = {
    firefox.enable = true;
    kitty.enable = true;
  };

}
