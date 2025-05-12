_:
rec {
  userName = "deck";
  email = "ltlr@posteo.de";
  localization = {
    locale = "en_IE.UTF-8"; # english with european units/time
    timezone = "Europe/Berlin";
    keymap = "de";
  };
  git = {
    inherit email;
    userName = "leoTlr";
  };

}
