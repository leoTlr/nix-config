{ config, pkgs, commonSettings, ... }:

{
  home.packages = [ pkgs.git ];

  programs.git = {
    enable = true;
    userName = commonSettings.user.name;

    extraConfig = {
      rebase = {
        autosquash = true;
	      autostash = true;
      };
      push = {
        autoSetupRemote = true;
      };
      pull = {
        rebase = true;
      };
      merge = {
        conflictstyle = "diff3";
      };
      rerere = {
        enabled = true;
      };
      init = {
        defaultBranch = "main";
      };
    };
    
    # maybe some of them dont work because of escaping/shell specific things
    aliases = {
      gl = "config --global -l";
      reporoot = "rev-parse --show-toplevel";
      s = "status -sb";
      st = "status";
      aa = "add --all";
      c = "commit -m";
      cf = "commit --fixup";
      ca = "commit --amend";
      can = "commit --amend --no-edit";
      co = "checkout";
      com = "checkout main";
      coft = ''!f() { git checkout feature/''${1:?no branch name given}; }; f'';
      cobf = ''!f() { git checkout bugfix/''${1:?no branch name given}; }; f'';
      cob = "checkout -b";
      cobft = ''!f() { git checkout -b feature/''${1:?no branch name given}; }; f'';
      cobbf = ''!f() { git checkout -b bugfix/''${1:?no branch name given}; }; f'';
      del = "branch -d";
      delf = "branch -D";
      delr = ''!f() { git push origin :''${1:?no branch name given}; }; f'';
      delfr = ''!f() { git delr ''${1}; git delf $1; }; f'';
      br = "branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate";
      bclean = ''!f() { git branch --merged ''${1-main} | grep -v " ''${1-main}$" | xargs -r git branch -d; }; f'';
      lg = "!git log --pretty=format:\"%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr) [%an]\" --abbrev-commit -30 -n";
      l = "lg 5";
      ll = "lg 10";
      lm = "!git log --pretty=format:\"%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr) [%an]\" --abbrev-commit -30 main~1..HEAD";
      rbm = "rebase main";
      rbi = "rebase -i";
      rbim = "rebase -i main";
      rbc = "rebase --continue";
      rba = "rebase --abort";
      pop = "reset HEAD~1 --mixed";
      popf = "reset HEAD~1 --hard";
      ps = "push";
      psf = "push --force-with-lease";
      pl = "pull";
      ms = "merge --squash";
      mc = "merge --continue";
      ma = "merge --abort";
      gone-check = ''! git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '$2 == \"[gone]\" {print $1}' '';
      gone-clean = ''! git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '$2 == \"[gone]\" {print $1}' | xargs -r git branch -D'';
      clone-branches = "! git branch -a | sed -n \"/\\/HEAD /d; /\\/master$/d; /remotes/p;\" | xargs -L1 git checkout -t";
      unstage = "! git restore --staged $(git reporoot)";
    };

  };
  
}