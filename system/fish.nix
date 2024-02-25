{ pkgs, commonSettings, ... }:

{
  programs.fish.enable = true;
  users.users."${commonSettings.user.name}".shell = pkgs.fish;
}