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
    shellInit =
      "function digs; dig +short $argv[1] | uniq | head -n1; end";
  };

  home.packages = with pkgs; [
    broot # terminal file picker
    bat # cat
    ripgrep # grep
    eza # ls
    tealdeer # tldr client in rust
    dig
    btop
    killall
  ];

}
