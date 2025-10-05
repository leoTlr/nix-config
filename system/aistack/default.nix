{ config, lib, pkgs, cfglib, ... }:
let
  cfg = config.syslib.aistack;

  stackUnitNames = [
    "open-webui.service"
    "ollama.service"
  ];

  stackTool = pkgs.writeShellApplication {
    name = "ai";
    text = ''
      function usage() {
        echo "Usage: $0 <command>" >&2
        echo "Available commands: status start stop logs" >&2
        exit 1
      }
      if [ $# -ne 1 ]; then usage "$@"; fi;
      case "$1" in
        start) systemctl start aistack.target;;
        stop) systemctl stop aistack.target;;
        status) systemctl list-dependencies aistack.target;;
        logs) journalctl -f ${lib.concatStringsSep " " (builtins.map (item: "-u ${item}") stackUnitNames)};;
        *) usage "$@";;
      esac
      exit 0
    '';
  };
in
{
  options.syslib.aistack = with lib; {
    enable = mkEnableOption "aistack";
    ports = {
      open-webui = mkOption { type = types.port; default = 4444; };
      ollamaApi = mkOption { type = types.port; default = 11434; };
    };
    preloadModels = mkOption {
      type = types.listOf types.str;
      default = [
        "qwen3:30b"
        # "deepseek-r1:70b"
        # "gpt-oss:20b"
        "bge-m3:latest" # embedding model 8k context
      ];
    };
  };

  imports = cfglib.nixModulesIn ./.;

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ stackTool ];

    systemd.targets."aistack" = {
      requires = stackUnitNames;
      after = [ "traefik.service" ];
      wants = [ "traefik.service" ];
      wantedBy = [ "default.target" ];
    };

    syslib.appproxy.apps.ai = {
      routeTo = "http://localhost:${builtins.toString cfg.ports.open-webui}";
      auth = false; # has its own auth that I cant disable
    };

  };
}
