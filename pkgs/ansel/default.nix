{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
  atk,
  cairo,
  cmake,
  curl,
  dbus-glib,
  exiv2,
  glib,
  gtk3,
  ilmbase,
  intltool,
  lcms,
  lensfun,
  libexif,
  libjpeg,
  libpng,
  librsvg,
  libtiff,
  libxcb,
  openexr,
  pixman,
  pkgconfig,
  sqlite,
  libxslt,
  libsoup,
  graphicsmagick,
  json-glib,
  openjpeg,
  lua5_3_compat,
  pugixml,
  colord,
  colord-gtk,
  libxshmfence,
  libxkbcommon,
  at-spi2-core,
  libwebp,
  libsecret,
  wrapGAppsHook,
  gnome,
  xorg,
  osm-gps-map,
  ocl-icd,
}:
stdenv.mkDerivation rec {
  # TODO
  # - https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/graphics/darktable/default.nix
  # - https://github.com/aurelienpierreeng/ansel/issues/202
  name = "ansel-git";

  src = lib.cleanSource (fetchFromGitHub {
    owner = "aurelienpierreeng";
    repo = "ansel";
    rev = "57ed58dd565a6c23224cf9a6d2dc63e096118a36";
    hash = "sha256-Hf0GevT56YKw2cXDI85SwqYC/MwIPQ/TTdysgOY2lm0=";
    fetchSubmodules = true;
  });

  nativeBuildInputs = [git];

  # xorg.libX11
  # gnome.adwaita-icon-theme
  buildInputs = with xorg; with gnome; [atk cairo cmake curl dbus-glib exiv2 glib gtk3 ilmbase intltool lcms lensfun libX11 libexif libjpeg libpng librsvg libtiff libxcb openexr pixman pkgconfig sqlite libxslt libsoup graphicsmagick json-glib openjpeg lua5_3_compat pugixml colord colord-gtk libxshmfence libxkbcommon at-spi2-core libwebp libsecret wrapGAppsHook adwaita-icon-theme osm-gps-map ocl-icd];

  cmakeFlags = ["-DBUILD_USERMANUAL=False"];

  # ansel changed its rpath handling in commit
  # 83c70b876af6484506901e6b381304ae0d073d3c and as a result the
  # binaries can't find libansel.so, so change LD_LIBRARY_PATH in
  # the wrappers:
  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH ":" "$out/lib/ansel:${ocl-icd}/lib"
    )
  '';

  meta = with lib; {
    description = "A darktable fork minus the bloat plus some design vision.";
    homepage = "https://ansel.photos/";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
