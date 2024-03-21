{ inputs, lib, config, commonSettings, ... }:

let
  cfg = config.homelib.firefox; 
  settings = import ./settings.nix {};
  extensions = with inputs.firefox-addons.packages."${commonSettings.system.arch}"; [
    ublock-origin
    decentraleyes
    cookie-autodelete
    privacy-redirect
    canvasblocker
    consent-o-matic
  ];
in
{
  options.homelib.firefox = {

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install and configure firefox";
    };

    extensions.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "Manage firefox addons";
    };

  };

  config = {
    programs.firefox = lib.mkIf cfg.enable {
      enable = true;

      profiles = {
        default = {
          id = 0;
          inherit settings;
          extensions = lib.mkIf cfg.extensions.enable extensions;
        };
      };
    };
  };
  
}