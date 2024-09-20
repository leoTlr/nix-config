{ ... }:

{

  imports = [
    ./hardware-configuration.nix
    ../../profiles/desktop/system
  ];

  profiles.base = {

    system = {
      hostName = "lt-t14";
      stateVersion = "23.11";
    };

  };

  profiles.desktop.enable = true;

}

