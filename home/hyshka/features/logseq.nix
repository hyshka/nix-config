{pkgs, ...}: {
  home.packages = with pkgs; [
    logseq
  ];
  # TODO: doesn't work
  nixpkgs.config.permittedInsecurePackages = [
    "electron-27.3.11"
  ];
}
