{ config, lib, ... }:
let
  cfg = config.syslib.sops;
in
{
  options.syslib.sops = {
    enable = lib.mkEnableOption "sops";
    gnupgHome = lib.mkOption {
      type = lib.types.path;
      description = "$GNUPGHOME used for secret decryption";
    };
  };

  config = lib.mkIf cfg.enable {
    
    sops = {
      defaultSopsFile = ../secrets.yaml;
      defaultSopsFormat = "yaml";
      gnupg.home = cfg.gnupgHome;
    };
  };

}