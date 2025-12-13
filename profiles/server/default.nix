{ config, lib, pkgs, cfglib, hostConfig, userConfig, ... }:
let
  cfg = config.profiles.server;
in
{
  options.profiles.server = with lib; {
    enable = mkEnableOption "server base profile";
    sshKey = mkOption {
      type = types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBTJPFx24iMt77z4a6unaq7EBMy8Hj+28vCZAJCbwdMi";
    };
    monitoring = mkEnableOption "grafana cloud metrics" // { default = true; };
  };

  config = lib.mkIf cfg.enable {

    profiles.base.enable = true;

    security.sudo.wheelNeedsPassword = lib.mkDefault false;
    networking.useNetworkd = lib.mkDefault true;

    sops = {
       defaultSopsFile = lib.mkDefault (cfglib.paths.hostSecretsFile hostConfig);
       gnupg = {
        home = lib.mkDefault "/root/.gnupg";
        sshKeyPaths = lib.mkDefault [];
      };
    };

    programs.gnupg.agent = {
      enable = lib.mkDefault true;
      pinentryPackage = lib.mkDefault pkgs.pinentry-tty;
    };

    syslib = {

      nix.remoteManaged = lib.mkDefault true;

      resourceControl.enable = lib.mkDefault true;

      sshd = {
        enable = lib.mkDefault true;
        authorizedKeys.${userConfig.userName} = lib.mkDefault [ cfg.sshKey ];
      };

      alloy.enable = lib.mkDefault cfg.monitoring;

    };

  };
}
