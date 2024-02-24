{ inputs, commonSettings, ... }:

let
  # ~/.mozilla/firefox/PROFILE_NAME/prefs.js | user.js
  settings = {
    "app.update.channel" = "default";
    "extensions.update.enabled" = false;

    "browser.contentblocking.category" = "standard"; # "strict"
    "browser.ctrlTab.recentlyUsedOrder" = false;
    "browser.link.open_newwindow" = true;
    "browser.search.widget.inNavBar" = true;
    "browser.shell.checkDefaultBrowser" = false;

    "browser.urlbar.placeholderName" = "DuckDuckGo";
    "browser.urlbar.showSearchSuggestionsFirst" = false;

    "privacy.donottrackheader.enabled" = true;

    "datareporting.policy.dataSubmissionEnabled" = false;
    "datareporting.healthreport.uploadEnabled" = false;

    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.server" = "data:,";
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.coverage.opt-out" = true; # [HIDDEN PREF]
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "toolkit.telemetry.shutdownPingSender.enabledFirstsession" = false;

    "toolkit.coverage.opt-out" = true; # [FF64+] [HIDDEN PREF]
    "toolkit.coverage.endpoint.base" = "";

    "browser.ping-centre.telemetry" = false; # (used in several System Add-ons) [FF57+]
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.vpn_promo.enabled" = false;
  };

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