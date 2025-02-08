{ config, lib, pkgs, ...}:
let
  cfg = config.homelib.helix;
in
{
  options.homelib.helix.enable = lib.mkEnableOption "helix editor";

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.helix
      pkgs.lazygit
    ];

    programs.helix = {
      enable = true;
      defaultEditor = true;

      # https://theari.dev/blog/enhanced-helix-config/
      settings = {

        theme = "gruvbox";

        editor = {
          # Show currently open buffers, only when more than one exists.
          bufferline = "multiple";
          # Highlight all lines with a cursor
          cursorline = true;
          # Show a ruler at column 120
          rulers = [ 120 ];
          # Force the theme to show colors
          true-color = true;
          # Minimum severity to show a diagnostic after the end of a line
          end-of-line-diagnostics = "hint";

          # different shapes per mode
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          indent-guides = {
            character = "╎";
            render = true;
            skip-levels = 2;
          };

          lsp = {
            # Disable automatically popups of signature parameter help
            auto-signature-help = false;
            # Show LSP messages in the status line
            display-messages = true;
          };

          statusline = {
            left = [
              "mode"
              "spinner"
              "version-control"
              "file-name"
            ];
          };

          inline-diagnostics = {
            cursor-line = "error"; # Show inline diagnostics when the cursor is on the line
            other-lines = "disable"; # Don't expand diagnostics unless the cursor is on the line
          };
        };

        keys = {
          normal = {
            A-x = "extend_to_line_bounds";
            X = "select_line_above";

            # buffer navigaion
            "A-," = "goto_previous_buffer";
            "A-." = "goto_next_buffer";
            "A-w" = ":buffer-close";
            "A-/" = "repeat_last_motion";

            # lazygit integration
            C-g = [
              ":write-all"
              ":new"
              ":insert-output ${lib.getExe pkgs.lazygit}"
              ":buffer-close!"
              ":redraw"
              ":reload-all"
            ];
          };
          select = {
            A-x = "extend_to_line_bounds";
            X = "select_line_above";
          };
        };        
      };

    };
  };
}
