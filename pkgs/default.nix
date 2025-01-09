# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{pkgs ? import <nixpkgs> {}}: rec {
  # example = pkgs.callPackage ./example { };
  ansel = pkgs.callPackage ./ansel {};
  zha_toolkit = pkgs.callPackage ./zha_toolkit {};
  kwin6-bismuth-decoration = pkgs.callPackage ./kwin6-bismuth-decoration {};
  snapraid-collector = pkgs.callPackage ./snapraid-collector {};
}
