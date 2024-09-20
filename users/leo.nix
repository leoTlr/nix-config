_:
{
  userName = "leo";
  email = "ltlr@posteo.de";
  gpg = {
    #inherit email;
    keys = {
      sign = "17F0A6278F9E22B4A846DAEAE0CF76180D567EDF";
      encrypt = "93822605C442D674624431B92F394641FD9E298A";
    };
  };
  localization = {
    locale = "en_IE.UTF-8"; # english with european units/time
    timezone = "Europe/Berlin";
    keymap = "de";
  };
}