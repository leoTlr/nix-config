{ config, lib, pkgs, inputs, ... }:
let 
  showSecret = (pkgs.writeShellScriptBin "show_secret" ''
    #!/usr/bin/env bash
    secret=''${1:?secret name not defined}
    echo "${config.sops.defaultSymlinkPath}/''${secret}"
    cat ${config.sops.defaultSymlinkPath}/''${secret}
  '');
in
{ 
  
  options.sops = {
    
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable sops";
    };

    showSecretScript.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.sops.enable;
      description = "Enable script show_secret SECRET_NAME";
    };

  };

  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  config = lib.mkIf config.sops.enable {

    sops = {
      defaultSopsFile = ../secrets.yaml;
      defaultSopsFormat = "yaml";

      # workaround until https://github.com/Mic92/sops-nix/issues/287 is fixed
      # Default is "%r/secrets" with "%r" supposed to be replaced with $XDG_RUNTIME_DIR
      # however replacement currently doesnt work leaving literal "%r" in the secret path
      defaultSymlinkPath = "${config.xdg.dataHome}/secrets";

      gnupg = {
        home = "${config.home.homeDirectory}/.gnupg";
        sshKeyPaths = [];
      };
    };

    home.packages = [ 
      pkgs.sops 
      (if config.sops.showSecretScript.enable then showSecret else null)
    ];
    # restart sops-nix automatically after home-manager switch
    home.activation.setupEtc = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      /run/current-system/sw/bin/systemctl --user start sops-nix
    '';

    gpg.enable = true;
    xdg.enable = true; # required for defaultSymlinkPath workaround
  
  };

}