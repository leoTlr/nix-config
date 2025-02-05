{ pkgs, lib, ...}:
let
  linuxSettings = {
    shellAliases = {
      sys = "systemctl";
      sysu = "systemctl --user";
      jctl = "journalctl";
      jctlu = "journalctl --user-unit";
    };
    packages = [
      pkgs.isd # systemd tui
    ];
  };
in
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
      la = "eza -lah";
      nsp = "nix-shell -p";
      rgf = "rg --files";
    } // lib.optionalAttrs pkgs.stdenv.isLinux linuxSettings.shellAliases;
    shellInit = ''
      function digs; dig +short $argv[1] | uniq | head -n1; end
      function mkcd; mkdir $argv[1] && cd $argv[1]; end
    '';
  };

  home.packages = with pkgs; [
    broot # terminal file picker
    ripgrep # grep
    eza # ls
    dig
    fd # find
    btop
    killall
    jq
  ] ++ lib.optionals pkgs.stdenv.isLinux linuxSettings.packages;

  # tldr client in rust https://github.com/tealdeer-rs/tealdeer
  programs.tealdeer = {
    enable = true;
    settings.updates = {
      auto_update = true;
      auto_update_interval_hours = 168; # 1w
    };
  };

}
