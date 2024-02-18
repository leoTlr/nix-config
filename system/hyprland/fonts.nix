{pkgs, ...}:

{
  
  fonts.packages = with pkgs; [
    # only dl specific fonts from nerdfonts repo
    (pkgs.nerdfonts.override {fonts = ["JetBrainsMono" "FiraCode"];})
  ];

  fonts.enableDefaultPackages = true;
  fonts.fontconfig = {
    defaultFonts = {
      monospace = ["JetBrainsMono Nerd Font Mono"];
      sansSerif = ["JetBrainsMono Nerd Font"];
      serif = ["JetBrainsMono Nerd Font"];
    };
  };

}