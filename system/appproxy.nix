{ config, lib, ... }:
let
  cfg = config.syslib.appproxy;

  mkAppType = fqdn: with lib;
    types.submodule ({ name, config, ... }: {
      options = {
        urlPath = mkOption { type = types.str; };
        service = mkOption { type = types.str; };
        tls = mkOption { type = types.bool; default = true; };
        auth = mkOption { type = types.bool; default = true; };
        routeTo = mkOption { type = types.nullOr types.str; default = null; };
        dynamicConfigAttrs = mkOption { readOnly = true; };
      };
      config = {
        urlPath = mkDefault "/${name}";
        service = mkDefault name;
        dynamicConfigAttrs = {
          http = {
            routers.${name} = {
              rule = "Host(`${fqdn}`) && PathPrefix(`${config.urlPath}`)";
              service = config.service;
              entrypoints = if config.tls then [ "websecure" ] else [ "web" ];
              tls.options = mkIf config.tls "default";
              middlewares = optionals config.auth [ "authelia@file" ];
            };
            services.${name} = mkIf (config.routeTo != null) {
              loadBalancer.servers = [{ url = config.routeTo; }];
            };
          };
        };
      };
    });

  appWithAuth = builtins.any
    (app: app.auth) (builtins.attrValues cfg.apps);

  tlsDynamicConfig = {
    tls = {
      options.default = {
        minVersion = "VersionTLS13";
        sniStrict = true;
      };
      stores.default.defaultCertificate = {
        inherit (cfg.tls) certFile;
        keyFile = cfg.tls.certKeyFile;
      };
      certificates = [{
        inherit (cfg.tls) certFile;
        keyFile = cfg.tls.certKeyFile;
      }];
    };
  };

  authDynamicConfig = {
    http.middlewares.authelia.forwardAuth = {
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

in
{
  options.syslib.appproxy = with lib; {
    enable = mkEnableOption "traefik reverse proxy";
    apps = mkOption {
      type = types.attrsOf (mkAppType cfg.fqdn);
      default = {};
    };
    fqdn = mkOption {
      type = types.str;
      description = ''
        fqdn for all apps. Subdomains unsupported. Apps reachable by url paths
      '';
    };
    tls = {
      certFile = mkOption { type = types.str;  example = ''config.sops.secrets."traefik/tls/cert".path''; };
      certKeyFile = mkOption { type = types.str;  example = ''config.sops.secrets."traefik/tls/certKey".path''; };
    };
    auth = {
      enable = (mkEnableOption "authelia") // { default = appWithAuth; };
      jwtSecretFile = mkOption { type = types.str; example = ''config.sops.secrets."authelia/jwtSecret".path''; };
      storageEncryptionKeyFile = mkOption { type = types.str; example = ''config.sops.secrets."authelia/storageEncryptionKeyFile".path''; };
      adminPassword = mkOption { type = types.str;  example = ''config.sops.placeholder."authelia/adminPassword"''; };
    };
  };

  config = lib.mkIf cfg.enable {

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

      dynamicConfigOptions =
      let
        merge = confs: builtins.foldl'
          (acc: confAttrs: lib.recursiveUpdate acc confAttrs)
          {} confs;
        confs =
          [ tlsDynamicConfig ]
          ++ lib.optionals cfg.auth.enable [ authDynamicConfig ]
          ++ (builtins.map (app: app.dynamicConfigAttrs) (lib.attrValues cfg.apps))
          ;
      in
        merge confs;
    };

    # default apps
    syslib.appproxy.apps = {
      traefik.service = "api@internal"; # traefik dashboard
      auth = { # authelia login screen
        routeTo = "http://127.0.0.1:${builtins.toString 9091}";
        auth = false; # protecting authelia with itself creates an infinite loop
      };
    };

    services.authelia.instances.main = lib.mkIf cfg.auth.enable {
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
            domain = [ "${cfg.fqdn}" "*.${cfg.fqdn}" ];
            policy = "one_factor"; # two_factor, bypass
          }];
        };
        session.cookies = [{
          domain = "${cfg.fqdn}";
          authelia_url = "https://${cfg.fqdn}/auth";
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
