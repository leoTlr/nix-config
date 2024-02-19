{pkgs, userSettings, ...}:

{
  programs.fish.enable = true;
  users.users."${userSettings.name}".shell = pkgs.fish;
}