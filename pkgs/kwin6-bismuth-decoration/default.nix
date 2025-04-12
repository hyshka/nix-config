# https://github.com/Ramblurr/nixcfg/blob/main/pkgs/kwin6-bismuth-decoration.nix
{
  lib,
  fetchFromGitHub,
  stdenv,
  pkgs,
}:
stdenv.mkDerivation rec {
  pname = "kwin6-bismuth-decoration";
  version = "ab6755fa1ca8d61535ff41e6a60d82b680847008";

  src = fetchFromGitHub {
    owner = "ivan-cukic";
    repo = pname;
    rev = "${version}";
    hash = "sha256-AXIyBRAW16pPVxWbhRcecCi9Lf3MsQMakSZD+a+BtSU=";
  };

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.extra-cmake-modules
  ];

  buildInputs = [
    pkgs.kdePackages.kcoreaddons
    pkgs.kdePackages.kwindowsystem
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
    maintainers = with maintainers; [maintainers.hyshka];
    homepage = "https://github.com/ivan-cukic/kwin6-bismuth-decoration";
    inherit (pkgs.kdePackages.kwindowsystem.meta) platforms;
  };
}
