{ config, lib, pkgs, cfglib, hostConfig, userConfig, ... }:
let
  cfg = config.profiles.server;
in
{
  options.profiles.server = with lib; {
    enable = mkEnableOption "server profile";
    sshKey = mkOption {
      type = types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBTJPFx24iMt77z4a6unaq7EBMy8Hj+28vCZAJCbwdMi";
    };
    metrics = mkEnableOption "grafana cloud metrics" // { default = true; };
  };

  config = lib.mkIf cfg.enable {

    profiles.base.enable = true;

    security.sudo.wheelNeedsPassword = lib.mkDefault false;
    networking.useNetworkd = lib.mkDefault true;
    services.fail2ban.enable = lib.mkDefault true;

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

      deploy = {
        role = "managed";
        connection = {
          sshUser = lib.mkDefault userConfig.userName;
          url = lib.mkDefault "${config.networking.hostName}.home.arpa";
        };
      };

      resourceControl.enable = lib.mkDefault true;

      sshd = {
        enable = lib.mkDefault true;
        authorizedKeys.${userConfig.userName} = lib.mkDefault [ cfg.sshKey ];
      };

      alloy.enable = lib.mkDefault cfg.metrics;

    };

  };
}
