{ inputs, ... }:
let
  pkgsFor = sys: inputs.nixpkgs.legacyPackages.${sys};
  homeConfigName = user: host: "${user}@${host}";
  homeManagerModules.default = ./home;
  nixosModules.default = ./system;
in
{

  mkSystem = hostConfig: user:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs hostConfig;
        userConfig = import (./. + "/users/${user}.nix") {};
      };
      modules = [
        (./. + "/hosts/${hostConfig}/configuration.nix")
        nixosModules.default
      ];
    };

  mkHome = sys: hostConfig: user:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor sys;
      extraSpecialArgs = {
        inherit inputs;
        homeConfig = homeConfigName user hostConfig;
        sysConfig = hostConfig;
        userConfig = import (./. + "/users/${user}.nix") {};
      };
      modules = [
        (./. + "/hosts/${hostConfig}/home.nix")
        homeManagerModules.default
      ];
    };

}