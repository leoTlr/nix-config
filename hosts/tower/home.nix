{ pkgs, userConfig, ... }:

{

  profiles = {
    base = {
      enable = true;
      stateVersion = "25.11";
    };
    desktop = {
      enable = true;
      monitors = [ "DP-1,3440x1440@164.9,0x0,1" ];
    };
  };

  homelib = {

    git.commitInfo.signKey = null;

    gammastep.location = {
      latPath = "/run/secrets/location/latitude";
      lonPath = "/run/secrets/location/longitude";
    };

  };

}
