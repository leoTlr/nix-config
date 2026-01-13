{ config, lib, pkgs, ... }:
let
  cfg = config.homelib.sops;

  showSecret = pkgs.writeShellScriptBin "show_secret" ''
    secret=''${1:?secret name not defined}
    echo "${config.sops.defaultSymlinkPath}/''${secret}"
    cat ${config.sops.defaultSymlinkPath}/''${secret}
  '';
in
{

  options.homelib.sops = with lib; {
    enable = lib.mkEnableOption "sops";
    userSopsFile = mkOption { type = types.nullOr types.path; };
    secrets = mkOption { type=types.attrs; default = {}; description="config.sops.secrets"; };
  };

  config = lib.mkIf cfg.enable {

    sops = {

      defaultSopsFile = lib.mkIf
        (cfg.userSopsFile != null) (lib.mkDefault cfg.userSopsFile);
      defaultSopsFormat = "yaml";

      gnupg = {
        home = "${config.home.homeDirectory}/.gnupg";
        sshKeyPaths = [];
      };

      inherit (cfg) secrets;
    };

    home.packages = [ pkgs.sops showSecret ];

    # restart sops-nix automatically after home-manager switch
    home.activation.setupEtc = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      /run/current-system/sw/bin/systemctl --user start sops-nix
    '';

  };

}
