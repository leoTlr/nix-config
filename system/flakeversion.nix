{ config, lib, cfglib, ... }:
let
  cfg = config.syslib.flakeRev;
in
{
  options.syslib.flakeRev.enable = lib.mkEnableOption "expose flake revision as file";

  config = lib.mkIf cfg.enable {

    environment.etc."gitversion" = {
      text = cfglib.flakeRev + "\n";
      mode = "0444";
    };

    # for `nixos-version --configuration-revision`
    system.configurationRevision = cfglib.flakeRev;

  };

}
