{ cfg, pkgs, ... }:
let
  c = cfg.nixBuild;
  check_worktree = pkgs.writeShellApplication {
    name = "check_worktree";
    runtimeInputs = [ pkgs.git ];
    text = ''
      #!/bin/env bash

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
in
''
set working-directory := '${c.flakePath}'

alias s := sys
sys:
  git add --all .
  ${pkgs.nh}/bin/nh os switch -H ${c.hostConfiguration} --ask .

alias h := home
home:
  git add --all .
  ${pkgs.nh}/bin/nh home switch --configuration ${c.homeConfiguration} --ask .

alias u := update
update: && sys home
  ${check_worktree}/bin/check_worktree
  nix flake update
  git add flake.lock
  git commit -m "system update"

''

