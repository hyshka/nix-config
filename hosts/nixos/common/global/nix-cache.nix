{
  lib,
  ...
}:
let
  atticKeyFile = ../../../../infra/attic/cache-public-key.txt;
  atticKey = lib.optionalString (builtins.pathExists atticKeyFile) (
    lib.removeSuffix "\n" (builtins.readFile atticKeyFile)
  );
in
{
  nix.settings = lib.mkMerge [
    { }
    (lib.mkIf (atticKey != "") {
      extra-substituters = [ "https://cache.home.hyshka.com/nix-config" ];
      extra-trusted-public-keys = [ atticKey ];
    })
  ];
}
