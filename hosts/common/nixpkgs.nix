{ outputs, lib, ... }:
{
  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        # Explicity add unfree packages for NixOS
        "steam"
        "steam-unwrapped"
        "fmod"
      ];
  };
}
