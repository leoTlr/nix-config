{
  description = "Personal config preferences";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

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
    cfgLib = import ./cfglib.nix {inherit inputs commonSettings;};

    # shared between system and homeManager configs
    commonSettings = {
      localization = {
        locale = "en_IE.UTF-8";
        timezone = "Europe/Berlin";
        keymap = "de";
      };

      user = {
        name = "leo";
      };
    };
  in
    with cfgLib; {
      homeManagerModules.default = ./home;
      nixosModules.default = ./system;

      nixosConfigurations = {
        testbox = mkSystem "testbox";
        t14 = mkSystem "t14";
      };

      homeConfigurations = {
        "leo@testbox" = mkHome "x86_64-linux" "testbox";
        "leo@t14" = mkHome "x86_64-linux" "t14";
      };
    };
}
