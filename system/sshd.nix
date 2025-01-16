{ config, lib, ... }:
let
  cfg = config.syslib.sshd;
in
{
  options.syslib.sshd = with lib; {
    enable = mkEnableOption "sshd";
    authorizedKeys = mkOption {
      type = types.attrsOf (types.listOf types.str);
    };
  };

  config = lib.mkIf cfg.enable {

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = null;
        PasswordAuthentication = false;
      };
    };

    users.users = lib.attrsets.concatMapAttrs (userName: keys: {
      ${userName}.openssh.authorizedKeys.keys = keys;
    }) cfg.authorizedKeys;
  };

}
