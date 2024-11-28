_:
let
  # get patch file: git format-patch -1 <ref>
  patchPkg = pkg: patches:
    pkg.overrideAttrs (prev: {
      patches = (prev.patches or []) ++ patches;
    });
in

[
  (final: prev: {
    swaylock-effects = patchPkg prev.swaylock-effects [ ./swaylock-effects-graceperiod.patch ];
  })
]
