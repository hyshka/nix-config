# https://github.com/Ramblurr/nixcfg/blob/main/pkgs/kwin6-bismuth-decoration.nix
{
  lib,
  #, mkDerivation
  fetchFromGitHub,
  stdenv,
  pkgs,
  #, kdePackages
  #, kcoreaddons
  #, kwindowsystem
  #, plasma-framework
  #, systemsettings
  #, cmake
  #, extra-cmake-modules
}:
stdenv.mkDerivation rec {
  pname = "kwin6-bismuth-decoration";
  version = "603f3cca4d9b1c383a352f6e570a2e56138ecedb";

  src = fetchFromGitHub {
    owner = "ivan-cukic";
    repo = pname;
    rev = "${version}";
    hash = "sha256-4M8LwnR7Cl/iN2PR+pX0vauOyyilbPEtzFxTxD2ouA8=";
  };

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.extra-cmake-modules
    #esbuild
  ];

  buildInputs = [
    pkgs.kdePackages.kcoreaddons
    pkgs.kdePackages.kwindowsystem
    #pkgs.kdePackages.plasma-framework
    pkgs.kdePackages.systemsettings
    pkgs.kdePackages.wrapQtAppsHook
    pkgs.kdePackages.qtbase
    pkgs.kdePackages.qtsvg
    pkgs.kdePackages.frameworkintegration
    pkgs.kdePackages.libplasma
    pkgs.kdePackages.ki18n
    pkgs.kdePackages.kdeclarative
    pkgs.kdePackages.kdecoration
  ];

  meta = with lib; {
    description = "Bismuth window decoration for kwin 6";
    license = licenses.mit;
    maintainers = with maintainers; [];
    homepage = "https://github.com/ivan-cukic/kwin6-bismuth-decoration";
    inherit (pkgs.kdePackages.kwindowsystem.meta) platforms;
  };
}
