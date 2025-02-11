{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib; 
  
  pkgsFor = sys: inputs.nixpkgs.legacyPackages.${sys};
  homeConfigName = user: host: "${user}@${host}";
  homeManagerModules.default = ./home;
  nixosModules.default = ./system;

  darwinModules =
    inputs.nixpkgs.lib.optionals
    (pkgsFor "aarch64-darwin").stdenv.isDarwin [
      inputs.mac-app-util.homeManagerModules.default
    ];

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

  cfglib = { inherit nixModulesIn; };
in
{

  mkSystem = hostConfig: user:
    lib.nixosSystem {
      specialArgs = {
        inherit inputs hostConfig cfglib;
        userConfig = import (./. + "/users/${user}.nix") {};
      };
      modules = [
        (./. + "/hosts/${hostConfig}/configuration.nix")
        (./. + "/hosts/${hostConfig}/hardware-configuration.nix")
        nixosModules.default
        (_: { nixpkgs.overlays = import ./overlays {}; })
      ];
    };

  mkHome = sys: hostConfig: user:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor sys;
      extraSpecialArgs = {
        inherit inputs cfglib;
        homeConfig = homeConfigName user hostConfig;
        sysConfig = hostConfig;
        userConfig = import (./. + "/users/${user}.nix") {};
      };
      modules = [
        (./. + "/hosts/${hostConfig}/home.nix")
        homeManagerModules.default
        (_: { nixpkgs.overlays = import ./overlays {}; })
      ] ++ darwinModules;
    };

}
