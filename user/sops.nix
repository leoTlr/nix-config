{ config, lib, pkgs, inputs, ... }:

{ 
  
  options.sops.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable sops";
  };

  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  config = lib.mkIf config.sops.enable {

    sops = {
      defaultSopsFile = ../secrets.yaml;
      defaultSopsFormat = "yaml";

      gnupg = {
        home = "${config.home.homeDirectory}/.gnupg";
        sshKeyPaths = [];
      };
    };

    home.packages = [ pkgs.sops ];
    # restart sops-nix automatically after home-manager switch
    home.activation.setupEtc = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      /run/current-system/sw/bin/systemctl --user start sops-nix
    '';

    gpg.enable = true;
  
  };

}