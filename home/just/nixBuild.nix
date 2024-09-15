{ cfg }:
let
  c = cfg.nixBuild;
in
''
set working-directory := '${c.flakePath}'

alias s := sys
sys:
  git add --all .
  nh os switch -H ${c.hostConfiguration} --ask

alias h := home
home:
  git add --all .
  nh home switch --configuration ${c.homeConfiguration} --ask

alias u := update
update: && sys home
  nix flake update


''

