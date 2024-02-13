{
  description = "Personal config preferences";
  
  inputs = {
    
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  
  outputs = { self, nixpkgs, home-manager, ... }:
    let
      
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      localeSettings = {
        locale = "en_IE.UTF-8";
        timezone = "Europe/Berlin";
        keymap = "de";
      };

      userSettings = {
        name = "leo";
      };

    in {
      
      nixosConfigurations = {
        testbox = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/testbox/configuration.nix ];
          specialArgs = {
            inherit localeSettings userSettings;
          };
        };
      };

      homeConfigurations = {
        "${userSettings.name}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [./hosts/testbox/home.nix ];
          extraSpecialArgs = {
            inherit localeSettings userSettings;
          };
        };
      };

    };
  
}