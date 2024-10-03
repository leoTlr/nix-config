{
  description = "Personal config preferences";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
  };

  outputs = inputs: let
    cfgLib = import ./cfglib.nix {inherit inputs;};
  in
    with cfgLib; {
      homeManagerModules.default = ./home;
      nixosModules.default = ./system;

      nixosConfigurations = {
        testbox = mkSystem "testbox" "leo";
        t14 = mkSystem "t14" "leo";
      };

      homeConfigurations = {
        "leo@testbox" = mkHome "x86_64-linux" "testbox" "leo";
        "leo@t14" = mkHome "x86_64-linux" "t14" "leo";
      };
    };
}
