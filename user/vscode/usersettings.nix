_:

{ 
  files.autoSave = "afterDelay";
  files.autoSaveDelay = 1500;
  files.trimTrailingWhitespace = true;

  diffEditor.ignoreTrimWhitespace = false;

  # https://github.com/nix-community/vscode-nix-ide
  nix.enableLanguageServer = true;
  nix.serverPath = "nixd";
}