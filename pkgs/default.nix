# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{pkgs ? import <nixpkgs> {}}: rec {
  # example = pkgs.callPackage ./example { };
  ansel = pkgs.callPackage ./ansel {};
  zha_toolkit = pkgs.callPackage ./zha_toolkit {};
  custom-caddy = pkgs.callPackage ./caddy {};
}
