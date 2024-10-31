{ config, lib, pkgs, ... }:
let
  cfg = config.homelib.zed;

  extensionDeps = with pkgs; {
    "nix" = [ nixd ];
  };
in
{
  options.homelib.zed = with lib; {
    enable = mkEnableOption "zed editor";
    extensions = mkOption {
      type = types.listOf types.str;
      default = [ "nix" ];
      description = ''
        Extensions to use.
        See [extension list](https://github.com/zed-industries/extensions/tree/main/extensions)"
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    programs.zed-editor = {
      enable = true;
      extensions = cfg.extensions;

      userSettings = {
        telemetry.metrics = false;
        autosave.after_delay.milliseconds = 1000;
        features.copilot = false;
        git = {
          git_gutter = "tracked_files"; # "tracked_files"|"hide"
          inline_blame = {
            enabled = true;
            delay_ms = "250";
            show_commit_summary = true;
          };
        };
        theme = {
          mode = "dark";
          dark = "Gruvbox Dark";
          light = "Gruvbox Light";
        };
        languages.Nix.tab_size = 2;
      };
    };

    home.packages = with builtins;
      foldl' (acc: ext:
        if (hasAttr ext extensionDeps)
        then acc ++ extensionDeps."${ext}"
        else acc
      ) [] cfg.extensions;
  };
}
