{ ... }:

{

  profiles.base = {
    enable = true;
    stateVersion = "25.05";
    sysConfigName = null;
  };

  homelib = {
    statix.enable = true;
    sops.enable = false;

    firefox.enable = true;
    vscode.enable = true;
    kitty.enable = true;
  };

}
