{ cfg, lib, pkgs, ... }:
let
  check_worktree = pkgs.writeShellApplication {
    name = "check_worktree";
    runtimeInputs = [ pkgs.git ];
    text = ''
      function exit_err {
        echo >&2 "Your worktree is dirty:"
        git status --porcelain=v1
        echo >&2 "Please clean up first"
        exit 1
      }

      git update-index --refresh
      git diff-index --quiet HEAD -- || exit_err
    '';
  };

  sysSwitch = ''
    alias s := sys
    sys:
      git add --all .
      ${pkgs.nh}/bin/nh os switch -H ${cfg.hostConfiguration} --ask .
  '';

  homeSwitch = ''
    alias h := home
    home:
      git add --all .
      ${pkgs.nh}/bin/nh home switch --configuration ${cfg.homeConfiguration} --ask .
  '';

  flakeUpdateDeps = cfg:
    (if (cfg.hostConfiguration != null) then "sys " else "") +
    (if (cfg.homeConfiguration != null) then "home" else "");

  flakeUpdate = ''
    alias u := update
    update: && ${flakeUpdateDeps cfg}
      ${check_worktree}/bin/check_worktree
      nix flake update
      git add flake.lock
      git commit -m "system update"
  '';

  modules = [ "set working-directory := '${cfg.flakePath}'\n" ]
    ++ (lib.optionals (cfg.hostConfiguration != null) [ sysSwitch ])
    ++ (lib.optionals (cfg.homeConfiguration != null) [ homeSwitch ])
    ++ [ flakeUpdate ];
in

lib.strings.concatStringsSep "\n" modules
