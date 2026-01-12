{ config, lib, ... }:
let
  cfg = config.syslib.arrstack.recyclarr;
in
{
  options.syslib.arrstack.recyclarr = with lib; {
    enable = mkEnableOption "recyclarr";
    apiKeyPaths = {
      radarr = mkOption { type = types.str; };
      sonarr = mkOption { type = types.str; };
    };
  };

  config = lib.mkIf cfg.enable {

    users.users.recyclarr = {
      uid = 704;
      group = "recyclarr";
      home = "/var/lib/recyclarr";
      description = "recyclarr user";
    };

    users.groups.recyclarr.gid = 704;

    systemd.services.recyclarr.serviceConfig.LoadCredential = [
      "radarr-api_key:${cfg.apiKeyPaths.radarr}"
      "sonarr-api_key:${cfg.apiKeyPaths.sonarr}"
    ];

    systemd.timers.recyclarr.enable = false; # workaround

    services.recyclarr = {
      enable = true;
      configuration = {

        radarr.radarr_main = {
          base_url = "http://localhost:7878/radarr";
          api_key._secret = "/run/credentials/recyclarr.service/radarr-api_key";
          delete_old_custom_formats = true;
          replace_existing_custom_formats = true;

          include = [
            { template = "radarr-quality-definition-movie"; }
            { template = "radarr-custom-formats-hd-bluray-web-german"; }
            { template = "radarr-quality-profile-hd-bluray-web-german"; }
          ];

          media_naming = {
            folder = "jellyfin-tmdb";
            movie = {
              rename = true;
              standard = "jellyfin-tmdb";
            };
          };

          quality_profiles = [{
            name = "HD Bluray + WEB (GER)";
            min_format_score = 10000; # skip English Releases
            reset_unmatched_scores.enabled = true; # fix stacking rules bug
          }];

          # https://github.com/recyclarr/config-templates/blob/3a2c4796b3aee5ccd4e66642bcd777ad38e0d739/radarr/templates/german-hd-bluray-web.yml
          custom_formats = [{
            trash_ids = [
              "839bea857ed2c0a8e084f3cbdbd65ecb" # allow HDR/DV x265 HD releases
            ];
            assign_scores_to = [{
              name = "HD Bluray + WEB (GER)";
            }];
          }];
        };

        sonarr.sonarr_main = {
          base_url = "http://localhost:8989/sonarr";
          api_key._secret = "/run/credentials/recyclarr.service/sonarr-api_key";
          delete_old_custom_formats = true;
          replace_existing_custom_formats = true;

          include = [
            { template = "sonarr-quality-definition-series"; }
            { template = "sonarr-v4-custom-formats-hd-bluray-web-german"; }
            { template = "sonarr-v4-quality-profile-hd-bluray-web-german"; }
          ];

          media_naming = {
            series = "jellyfin-tvdb";
            season = "default";
            episodes = {
              rename = true;
              standard = "default";
              daily = "default";
            };
          };

          quality_profiles = [{
            name = "HD Bluray + WEB (GER)";
            min_format_score = 10000; # skip English Releases
            reset_unmatched_scores.enabled = true; # fix stacking rules bug
          }];

          # https://github.com/recyclarr/config-templates/blob/3a2c4796b3aee5ccd4e66642bcd777ad38e0d739/sonarr/templates/german-hd-bluray-web-v4.yml
          custom_formats = [{
            trash_ids = [
              "9b64dff695c2115facf1b6ea59c9bd07" # allow only HDR/DV x265 HD releases
            ];
            assign_scores_to = [{
              name = "HD Bluray + WEB (GER)";
            }];
          }];
        };

      };
    };

  };
}
