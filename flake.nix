{
  description = "Personal config preferences";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-23-05.url = "github:NixOS/nixpkgs/nixos-23.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-colors.url = "github:misterio77/nix-colors";
    hyprcursor-phinger ={
      url = "github:jappie3/hyprcursor-phinger";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }:
  let
    cfgLib = import ./cfglib.nix { inherit self; };
    lib = self.inputs.nixpkgs.lib;
  in
    with cfgLib; {

      nixosConfigurations = with self.inputs; {
        t14 = mkSystem "x86_64-linux" "t14" "leo" nixpkgs-unstable;
        bee = mkSystem "x86_64-linux" "bee" "leo" nixpkgs;
        tower = mkSystem "x86_64-linux" "tower" "leo" nixpkgs;
        sparrow = mkSystem "x86_64-linux" "sparrow" "leo" nixpkgs;
        h0 = mkSystem "x86_64-linux" "h0" "leo" nixpkgs;
      };

      homeConfigurations = with self.inputs; {
        "leo@t14" = mkHome "x86_64-linux" "t14" "leo" home-manager-unstable;
        "leo@tower" = mkHome "x86_64-linux" "tower" "leo" home-manager;
        "ji09br@APM3LJDY9D2K7HC" = mkHome "aarch64-darwin" "APM3LJDY9D2K7HC" "ji09br" home-manager;
        "deck@deck" = mkHome "x86_64-linux" "deck" "deck" home-manager;
      };

      packages = forEachSystem
        (system: import ./pkgs { pkgs = (import self.inputs.nixpkgs { inherit system; }); });

      overlays = import ./overlays {};

      devShells = forEachSystem
        (system: import ./shells { inherit system self; });

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks  self.deploy)
        self.inputs.deploy-rs.lib;

      deploy.nodes =
      let
        managedNodes = lib.attrsets.filterAttrs
          (_: val: with val.config.syslib.deploy; role == "managed" || role == "both")
          self.nixosConfigurations;
      in
        builtins.mapAttrs mkDeployNode managedNodes;

    };
}
