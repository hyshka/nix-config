{outputs, ...}: {
  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      # TODO: move to logseq.nix module
      permittedInsecurePackages = [
        "electron-27.3.11"
      ];
    };
  };
}
