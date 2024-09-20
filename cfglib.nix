{ inputs, ... }:
let
  inherit (inputs.self) outputs;
  pkgsFor = sys: inputs.nixpkgs.legacyPackages.${sys};
  homeConfigName = user: host: "${user}@${host}";
in
{

  mkSystem = hostConfig: user:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs hostConfig;
        userConfig = import (./. + "/users/${user}.nix") {};
      };
      modules = [
        (./. + "/hosts/${hostConfig}/configuration.nix")
        outputs.nixosModules.default
      ];
    };

  mkHome = sys: hostConfig: user:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor sys;
      extraSpecialArgs = {
        inherit inputs outputs;
        homeConfig = homeConfigName user hostConfig;
        sysConfig = hostConfig;
        userConfig = import (./. + "/users/${user}.nix") {};
      };
      modules = [
        (./. + "/hosts/${hostConfig}/home.nix")
        outputs.homeManagerModules.default
      ];
    };

}