_:
{
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
  
}
