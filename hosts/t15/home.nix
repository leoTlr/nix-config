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
        # "eDP-1,1920x1080@60,0x0,1"
        # "DP-1,1920x1080@60,1920x0,1"
        # "DP-2,1920x1080@60,3840x0,1"
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

}
