{ outputs, lib, ... }:
{
  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "claude-code"
      ];
  };
}
