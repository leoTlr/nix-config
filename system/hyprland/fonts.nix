{pkgs, ...}:

{
  
  fonts = {
    packages = with pkgs; [
      # only dl specific fonts from nerdfonts repo
      (pkgs.nerdfonts.override {fonts = ["JetBrainsMono" "FiraCode"];})
    ];

    enableDefaultPackages = true;
    fontconfig = {
      defaultFonts = {
        monospace = ["JetBrainsMono Nerd Font Mono"];
        sansSerif = ["JetBrainsMono Nerd Font"];
        serif = ["JetBrainsMono Nerd Font"];
      };
    };
  }; 
  
}