{ pkgs }:

{
  files= {
    autoSave = "afterDelay";
    autoSaveDelay = 1500;
    trimTrailingWhitespace = true;
  };

  diffEditor.ignoreTrimWhitespace = false;

  # https://github.com/nix-community/vscode-nix-ide
  nix = {
    enableLanguageServer = true;
    serverPath = "${pkgs.nixd}/bin/nixd";
  };
}