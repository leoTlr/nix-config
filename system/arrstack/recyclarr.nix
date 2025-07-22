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
            # min_format_score = 10000 # Uncomment this line to skip English Releases
          }];

          # https://github.com/recyclarr/config-templates/blob/3a2c4796b3aee5ccd4e66642bcd777ad38e0d739/radarr/templates/german-hd-bluray-web.yml
          custom_formats = [

            { ### Optional
              trash_ids = [
                # "b6832f586342ef70d9c128d40c07b872" # Bad Dual Groups
                # "ae9b7c9ebde1f3bd336a8cbd1ec4c5e5" # No-RlsGroup
                # "7357cf5161efbf8c4d5d0c30b4815ee2" # Obfuscated
                # "5c44f52a8714fdd79bb4d98e2673be1f" # Retags
                # "f537cf427b64c38c8e36298f657e4828" # Scene
              ];
              assign_scores_to = [{
                name = "HD Bluray + WEB (GER)";
              }];
            }

            { ### Movie Versions
              trash_ids = [
                # Uncomment any of the following lines to prefer these movie versions
                # "570bc9ebecd92723d2d21500f4be314c" # Remaster
                # "eca37840c13c6ef2dd0262b141a5482f" # 4K Remaster
                # "e0c07d59beb37348e975a930d5e50319" # Criterion Collection
                # "9d27d9d2181838f76dee150882bdc58c" # Masters of Cinema
                # "db9b4c4b53d312a3ca5f1378f6440fc9" # Vinegar Syndrome
                # "957d0f44b592285f26449575e8b1167e" # Special Edition
                # "eecf3a857724171f968a66cb5719e152" # IMAX
                # "9f6cbff8cfe4ebbc1bde14c7b7bec0de" # IMAX Enhanced
              ];
              assign_scores_to = [{
                name = "HD Bluray + WEB (GER)";
              }];
            }

            { ### x265 - IMPORTANT: Only use on of the options below.
              trash_ids = [
                "839bea857ed2c0a8e084f3cbdbd65ecb" # Uncomment this line to allow HDR/DV x265 HD releases
              ];
              assign_scores_to = [{
                name = "HD Bluray + WEB (GER)";
              }];
            }
            {
              trash_ids = [
                # "dc98083864ea246d05a42df0d05f81cc" # Uncomment this line to block all x265 HD releases
              ];
              assign_scores_to = [{
                name = "HD Bluray + WEB (GER)";
                score = -35000;
              }];
            } ### /x265

            { ### Generated Dynamic HDR
              trash_ids = [
                "e6886871085226c3da1830830146846c" # Uncomment this line to block Generated Dynamic HDR
              ];
              assign_scores_to = [{
                name = "HD Bluray + WEB (GER)";
                score = -35000;
              }];
            }
          ];
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
            # min_format_score: 10000 # Uncomment this line to skip English Releases
          }];

          # https://github.com/recyclarr/config-templates/blob/3a2c4796b3aee5ccd4e66642bcd777ad38e0d739/sonarr/templates/german-hd-bluray-web-v4.yml
          custom_formats = [

            { ### Optional
              trash_ids = [
                # "32b367365729d530ca1c124a0b180c64" # Bad Dual Groups
                # "82d40da2bc6923f41e14394075dd4b03" # No-RlsGroup
                # "e1a997ddb54e3ecbfe06341ad323c458" # Obfuscated
                # "06d66ab109d4d2eddb2794d21526d140" # Retags
                # "1b3994c551cbb92a2c781af061f4ab44" # Scene
              ];
              assign_scores_to = [{
                name = "HD Bluray + WEB (GER)";
              }];
            }

            { ### x265 - IMPORTANT: Only use on of the options below.
              trash_ids = [
                "9b64dff695c2115facf1b6ea59c9bd07" # Uncomment this to allow only HDR/DV x265 HD releases
              ];
              assign_scores_to = [{
                name = "HD Bluray + WEB (GER)";
              }];
            }
            {
              trash_ids = [
                # "47435ece6b99a0b477caf360e79ba0bb" # Uncomment this to block all x265 HD releases
              ];
              assign_scores_to = [{
                name = "HD Bluray + WEB (GER)";
                score = -35000;
              }];
            } ### /x265

          ];
        };
      };
    };

  };
}
