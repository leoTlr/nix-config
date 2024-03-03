{ inputs, commonSettings, ... }:

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

  programs.firefox = {
    enable = true;

    profiles = {
      default = {
        id = 0;
        inherit settings extensions;
      };
    };
  };

}