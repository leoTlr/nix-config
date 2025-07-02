{ config, lib, pkgs, userConfig, cfglib, ... }:
let
  cfg = config.homelib.sops;
  showSecret = pkgs.writeShellScriptBin "show_secret" ''
    secret=''${1:?secret name not defined}
    echo "${config.sops.defaultSymlinkPath}/''${secret}"
    cat ${config.sops.defaultSymlinkPath}/''${secret}
  '';
in
{ 
  
  options.homelib.sops = {
    
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable sops";
    };

    showSecretScript.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "Enable script show_secret SECRET_NAME";
    };

  };

  config = lib.mkIf cfg.enable {

    sops = {
      defaultSopsFile = cfglib.paths.userSecretsFile userConfig.userName;
      defaultSopsFormat = "yaml";

      gnupg = {
        home = "${config.home.homeDirectory}/.gnupg";
        sshKeyPaths = [];
      };
    };

    home.packages = [ pkgs.sops ]
      ++ lib.optionals cfg.showSecretScript.enable [ showSecret ];

    # restart sops-nix automatically after home-manager switch
    home.activation.setupEtc = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      /run/current-system/sw/bin/systemctl --user start sops-nix
    '';

    homelib.gpg.enable = true;
  
  };

}
