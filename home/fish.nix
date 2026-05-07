{ pkgs, lib, config, ...}:
let
  cfg = config.homelib.fish;

  linuxSettings = {
    shellAliases = {
      sys = "systemctl";
      sysu = "systemctl --user";
      jctl = "journalctl";
      jctlu = "journalctl --user-unit";
    };
    packages = [ ];
  };
in
{
  options.homelib.fish.enable = lib.mkEnableOption "fish shell";

  config = lib.mkIf cfg.enable {

    programs.fish = {
      enable = true;

      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';

      shellAliases = {
        ".." = "cd ..";
        "..." = "cd ../..";
        g = lib.getExe pkgs.git;
        ls = lib.getExe pkgs.eza;
        la = lib.getExe pkgs.eza + " -lah";
        rgf = lib.getExe pkgs.ripgrep + " --files";
        rg = lib.getExe pkgs.ripgrep + " --ignore-case";
        tldr = "tldr --platform linux";
        tldrm = "tldr --platform macos";
      } // lib.optionalAttrs pkgs.stdenv.isLinux linuxSettings.shellAliases;

      shellInit = ''
        function digs; dig +short $argv[1] | uniq | head -n1; end
        function mkcd; mkdir $argv[1] && cd $argv[1]; end
        function icat; kitten icat $argv[1]; end #show images in kitty terminal
        function nsp
          set --local --export NIXPKGS_ALLOW_UNFREE 1
          set --local --export NIXPKGS_ALLOW_INSECURE 1
          nix shell --impure nixpkgs#$argv
        end
        function y --description 'yazi with cd-on-exit'
          set -l tmp (mktemp -t yazi-cwd.XXXXXX)
          ${lib.getExe pkgs.yazi} $argv --cwd-file="$tmp"
          if test -s "$tmp"
            set -l cwd (cat -- $tmp)
            if test -n "$cwd"; and test "$cwd" != "$PWD"
              cd -- "$cwd"
                commandline -f repaint
            end
          end
          rm -f -- "$tmp"
        end
      '';
    };

    home.packages = with pkgs; [
      yazi # terminal file picker
      ripgrep # grep
      eza # ls
      dig
      fd # find
      btop
      killall
      jq
      tlrc # tldr client
    ] ++ lib.optionals pkgs.stdenv.isLinux linuxSettings.packages;

    services.tldr-update = {
      enable = true;
      package = pkgs.tlrc;
      period = "daily";
    };

  };

}
