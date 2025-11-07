# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{
  pkgs ? import <nixpkgs> { },
}:
rec {
  # example = pkgs.callPackage ./example { };
  ansel = pkgs.callPackage ./ansel { };
  snapraid-collector = pkgs.callPackage ./snapraid-collector { };
}
