{pkgs, ...}:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      g = "git";
      ls = "eza";
      cat = "bat";
      sys = "systemctl";
      sysu = "systemctl --user";
    };
  };

  home.packages = with pkgs; [
    lf
    bat
    ripgrep
    eza
  ];

}