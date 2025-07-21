{ config, cfglib, lib, ... }:
let
  cfg = config.syslib.arrstack;
  # arrUser = "jack";
in
{
  options.syslib.arrstack = with lib; {
    enable = mkEnableOption "arrstack";
    domain = mkOption {
      type = types.str;
      default = "arr.home.arpa";
      # services accessible at custom paths
      # i.e. arr.home.arpa/traefik
    };
    proxy = {
      certFile = mkOption { type = types.str;  example = ''config.sops.secrets."traefik/tls/cert".path''; };
      certKeyFile = mkOption { type = types.str;  example = ''config.sops.secrets."traefik/tls/certKey".path''; };
    };
    auth = {
      jwtSecretFile = mkOption { type = types.str; example = ''config.sops.secrets."authelia/jwtSecret".path''; };
      storageEncryptionKeyFile = mkOption { type = types.str; example = ''config.sops.secrets."authelia/storageEncryptionKeyFile".path''; };
      adminPassword = mkOption { type = types.str;  example = ''config.sops.placeholder."authelia/adminPassword"''; };
    };
  };

  imports = cfglib.nixModulesIn ./.;

  config = lib.mkIf cfg.enable {

    # users = {
    #   users.${arrUser} = {
    #     isSystemUser = true;
    #     createHome = true;
    #   };
    #   groups.pirates.members = [ arrUser ];
    # };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.traefik = {
      enable = true;
      staticConfigOptions = {
        log.level = "INFO";
        accessLog = {};
        # log.level = "DEBUG";
        # accessLog.addInternals = true;
        entryPoints = {
          web = {
            address = ":80";
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
            };
          };
          websecure = {
            address = ":443";
            http.tls.options = "default";
          };
        };
        api = {
          dashboard = true;
          insecure = false;
          basePath = "/traefik";
        };
      };
      dynamicConfigOptions = {
        http = {
          routers = {
            dashboard = {
              rule = "Host(`${cfg.domain}`) && PathPrefix(`/traefik`)";
              service = "api@internal";
              entrypoints = [ "websecure" ];
              tls.options = "default";
              middlewares = [ "authelia@file" ];
            };
            auth = {
              rule = "Host(`${cfg.domain}`) && PathPrefix(`/auth`)";
              service = "auth";
              entrypoints = [ "websecure" ];
              tls.options = "default";
            };
          };
          services.auth.loadBalancer.servers = [{
            url = "http://127.0.0.1:${builtins.toString 9091}";
          }];
          middlewares.authelia.forwardAuth = {
            address = "http://127.0.0.1:9091/api/authz/forward-auth";
            trustForwardHeader = true;
            authResponseHeaders = [
              "Remote-User"
              "Remote-Groups"
              "Remote-Email"
              "Remote-Name"
            ];
          };
        };
        tls = {
          options.default = {
            minVersion = "VersionTLS13";
            sniStrict = true;
          };
          stores.default.defaultCertificate = {
            certFile = cfg.proxy.certFile;
            keyFile = cfg.proxy.certKeyFile;
          };
          certificates = [{
            certFile = cfg.proxy.certFile;
            keyFile = cfg.proxy.certKeyFile;
          }];
        };
      };
    };

    services.authelia.instances.main = {
      enable = true;
      settings = {
        theme = "auto";
        default_2fa_method = "totp";
        log.level = "info";
        server = {
          address = "tcp://127.0.0.1:9091/auth";
          disable_healthcheck = true;
        };
        authentication_backend.file.path = config.sops.templates."authelia-users.yaml".path;
        access_control = {
          default_policy = "deny";
          rules = [{
            domain = [ "${cfg.domain}" "*.${cfg.domain}" ];
            policy = "one_factor"; # two_factor, bypass
          }];
        };
        session.cookies = [{
          domain = "${cfg.domain}";
          authelia_url = "https://${cfg.domain}/auth";
          # default_redirection_url = "https://duckduckgo.com";
          name = "authelia_session";
          same_site = "lax"; # strict, none
          inactivity = "5m";
          expiration = "12h";
          remember_me = "2d";
        }];
        storage.local.path = "/var/lib/authelia-main/authelia_db.sqlite3";
        notifier.filesystem.filename = "/var/lib/authelia-main/notification.txt";
        regulation = {
          max_retries = 3;
          find_time = "5m";
          ban_time = "15m";
        };
      };
      secrets = {
        inherit (cfg.auth) jwtSecretFile storageEncryptionKeyFile;
      };
    };

    sops.templates."authelia-users.yaml" = {
      owner = "authelia-main";
      restartUnits = [ "authelia-main.service" ];
      content = ''
        users:
          admin:
            disabled: false
            displayname: 'admin'
            password: '${cfg.auth.adminPassword}'
            # email: 'foo@bar.com'
            groups:
              - 'admins'
      '';
    };
    
  };
}
