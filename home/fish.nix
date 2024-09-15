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
      jctl = "journalctl";
      jctlu = "journalctl --user-unit";
      nsp = "nix-shell -p";
    };
  };

  home.packages = with pkgs; [
    lf # terminal file manager
    bat # cat
    ripgrep # grep
    eza # ls
    tealdeer # tldr client in rust
  ];

}
