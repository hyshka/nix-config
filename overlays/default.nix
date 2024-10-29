# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    sunshine = prev.sunshine.overrideAttrs (oldAttrs: rec {
      extraLibraries = [
        prev.xorg.xrandr # can't remember why
        prev.util-linux # required for setsid
      ];
    });

    vkdt = prev.vkdt.overrideAttrs (oldAttrs: rec {
      version = "0.7.0";
      src = prev.fetchurl {
        url = "https://github.com/hanatos/${oldAttrs.pname}/releases/download/${version}/${oldAttrs.pname}-${version}.tar.xz";
        sha256 = "sha256-Sk/K+EWvJBkwwD5R1gH9ZQHetojrJTTJrKW9Dvr+lHA=";
      };
      buildInputs =
        oldAttrs.buildInputs
        ++ [
          prev.libxml2 # for xmllint optional dependency
        ];
    });
  };

  # Adds pkgs.stable == inputs.nixpkgs-stable.legacyPackages.${pkgs.system}
  stable = final: _: {
    stable = inputs.nixpkgs-stable.legacyPackages.${final.system};
  };
}
