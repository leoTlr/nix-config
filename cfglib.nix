{ inputs, commonSettings, ... }@args:
let
  cfgLib = inputs.cfgLib;
  outputs = inputs.self.outputs;
in
rec {
  
  mkSystem = hostconfig:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs outputs cfgLib commonSettings; };
      modules = [
        hostconfig
        outputs.nixosModules.default
      ];
    };

  mkHome = sys: config:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor sys;
      extraSpecialArgs = { inherit inputs outputs cfgLib commonSettings; };
      modules = [
        config
        outputs.homeManagerModules.default
      ];
    };

  pkgsFor = sys: inputs.nixpkgs.legacyPackages.${sys};

}