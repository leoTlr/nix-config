{ config, lib, pkgs, ...}:

{ 
  
  options.gpg.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable gpg and gpg-agent";
  };

  config = {
  
    programs.gpg.enable = true;
    
    services.gpg-agent = {
      enable = true;
      enableFishIntegration = true;
      pinentryFlavor = "curses";
    };

    home.packages = [ pkgs.pinentry-curses ];
  
  };

}