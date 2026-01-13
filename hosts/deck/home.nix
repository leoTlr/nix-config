{ ... }:

{

  profiles.base = {
    enable = true;
    stateVersion = "25.05";
    sysConfigName = null;
  };

  homelib = {
    statix.enable = true;
    firefox.enable = true;
    vscode.enable = true;
    kitty.enable = true;
  };

}
