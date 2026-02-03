_:

{

  profiles = {
    base = {
      enable = true;
      stateVersion = "26.05";
    };
    desktop = {
      enable = true;
      monitors = [
        "eDP-1,2560x1600@240,0x0,1.25,vrr,1"
        "DP-1,1920x1080@60,1920x0,1,vrr,1"
        "DP-2,1920x1080@60,3840x0,1,vrr,1"
      ];
    };
    secrets = {
      enable = true;
      secrets = {
        "location/latitude" = {};
        "location/longitude" = {};
      };
    };
  };

  homelib.hyprland.keyMap = "us";

}
