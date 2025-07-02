{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  pkgsFor = sys: inputs.nixpkgs.legacyPackages.${sys};
  homeConfigName = user: host: "${user}@${host}";
  optionalConfigFile = path:
    lib.optionals (lib.pathExists path) [ path ];

  cfgPaths =
  let
    nixosModules = ./system;
    hmModules = ./home;
    userConfigDir = ./users;
    hostConfigDir = ./hosts;
  in {
    inherit nixosModules hmModules userConfigDir hostConfigDir;
    hostConfigFile = host: hostConfigDir + "/${host}/configuration.nix";
    diskConfigFile = host: hostConfigDir + "/${host}/disko.nix";
    hardwareConfigFile = host: hostConfigDir + "/${host}/hardware-configuration.nix";
    homeConfigFile = host: hostConfigDir + "/${host}/home.nix";
    userConfigFile = user: userConfigDir + "/${user}.nix";
    userSecretsFile = user: userConfigDir + "/${user}.secrets.yaml";
  };

  # get modules below $dir even if they are in a directory (non-recursive)
  nixModulesIn = with builtins; dir:
  let
    # i.e. $dir/foo.nix, $dir/bar.nix
    flatModuleFilter = base: name: type:
      if type == "regular" && (lib.hasSuffix ".nix" name) && (name != "default.nix")
      then base + ("/" + name)
      else null;
    # i.e. $dir/foo/default.nix, $dir/bar/default.nix
    dirModuleFilter = base: name: type:
      if type == "directory" && (pathExists (base + "/${name}" + "/default.nix"))
      then base + "/${name}"
      else null;

    modules = moduleFileFilter: dir:
      lib.filter (val: val != null)
      (lib.mapAttrsToList (moduleFileFilter dir) (readDir dir));
    flatModules = dir: modules flatModuleFilter dir;
    dirModules = dir: modules dirModuleFilter dir;
  in
    (flatModules dir) ++ (dirModules dir);

  cfglib = {
    inherit nixModulesIn;
    paths = cfgPaths;
  };
 in
{

  mkSystem = hostConfig: user:
    lib.nixosSystem {
      specialArgs = {
        inherit inputs hostConfig cfglib;
        userConfig = import (cfglib.paths.userConfigFile user) {};
      };
      modules = [
        cfglib.paths.nixosModules
        inputs.disko.nixosModules.default
        (cfglib.paths.hostConfigFile hostConfig) 
      ]
      ++ optionalConfigFile (cfglib.paths.hardwareConfigFile hostConfig)
      ++ optionalConfigFile (cfglib.paths.diskConfigFile hostConfig)
      ++ [ (_: { nixpkgs.overlays = import ./overlays {}; }) ];
    };

  mkHome = sys: hostConfig: user:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor sys;
      extraSpecialArgs = {
        inherit inputs cfglib;
        homeConfig = homeConfigName user hostConfig;
        sysConfig = hostConfig;
        userConfig = import (cfglib.paths.userConfigFile user) {};
      };
      modules = [
        cfglib.paths.hmModules
        (cfglib.paths.homeConfigFile hostConfig)
        inputs.sops-nix.homeManagerModules.sops
        (_: { nixpkgs.overlays = import ./overlays {}; })
      ];
    };

}
