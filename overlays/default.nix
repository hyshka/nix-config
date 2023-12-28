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

    #nodePackages = prev.nodePackages // {
    #  "@vue/language-server" = prev.nodePackages."@vue/language-server".overrideAttrs (oldAttrs {
    #    version = 1.8.15;
    #    src = /Users/hyshka/Work/nixpkgs/result;
    #  });
    #};

    #etlegacy = inputs.nixpkgs.lib.callPackageWith (inputs.nixpkgs.pkgsi686Linux // prev.etlegacy);
    #etlegacy = prev.etlegacy.overrideAttrs (oldAttrs: let
    #  mirror = "https://mirror.etlegacy.com";
    #  fetchAsset = {
    #    asset,
    #    sha256,
    #  }:
    #    builtins.fetchurl
    #    {
    #      url = mirror + "/etmain/" + asset;
    #      inherit sha256;
    #    };
    #  pak0 = fetchAsset {
    #  asset = "pak0.pk3";
    #  sha256 = "712966b20e06523fe81419516500e499c86b2b4fec823856ddbd333fcb3d26e5";
    #  };
    #  pak1 = fetchAsset {
    #  asset = "pak1.pk3";
    #  sha256 = "5610fd749024405b4425a7ce6397e58187b941d22092ef11d4844b427df53e5d";
    #  };
    #  pak2 = fetchAsset {
    #  asset = "pak2.pk3";
    #  sha256 = "a48ab749a1a12ab4d9137286b1f23d642c29da59845b2bafc8f64e052cf06f3e";
    #  };

    #  mainProgram = "etl.i386";
    #in rec {
    #preBuild = ''
    #  # Required for build time to not be in 1980
    #  export SOURCE_DATE_EPOCH=$(date +%s)
    #  # This indicates the build was by a CI pipeline and prevents the resource
    #  # files from being flagged as 'dirty' due to potentially being custom built.
    #  export CI="true"
    #  # 32 bit
    #  export CC="gcc -m32"
    #  export CXX="g++ -m32"
    #'';

    #  postInstall = ''
    #    ETMAIN=$out/etmain
    #    mkdir -p $ETMAIN
    #    ln -s ${pak0} $ETMAIN/pak0.pk3
    #    ln -s ${pak1} $ETMAIN/pak1.pk3
    #    ln -s ${pak2} $ETMAIN/pak2.pk3
    #    makeWrapper $out/${mainProgram} $out/bin/${mainProgram} --chdir $out
    #  '';
    #});
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
