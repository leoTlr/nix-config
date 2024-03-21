{ inputs, lib, config, commonSettings, ... }:

let
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
  options.firefox = {

    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install and configure firefox";
    };

    extensions.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.firefox.enable;
      description = "Manage firefox addons";
    };

  };

  config = {
    programs.firefox = lib.mkIf config.firefox.enable {
      enable = true;

      profiles = {
        default = {
          id = 0;
          inherit settings;
          extensions = lib.mkIf config.firefox.extensions.enable extensions;
        };
      };
    };
  };
  
}