# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = _final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # Use llm-agents version of opencode instead of nixpkgs
    opencode = inputs.llm-agents.packages.${prev.stdenv.hostPlatform.system}.opencode;

    # Pin Incus to version 6.17.0
    incus = inputs.nixpkgs-incus-6-18.legacyPackages.${prev.stdenv.hostPlatform.system}.incus;

    sunshine = prev.sunshine.overrideAttrs (_oldAttrs: rec {
      extraLibraries = [
        prev.util-linux # required for setsid
      ];
    });

    # https://github.com/NixOS/nixpkgs/pull/476394
    pocket-id = prev.pocket-id.overrideAttrs (oldAttrs: rec {
      version = "2.0.0";
      src = prev.fetchFromGitHub {
        owner = "pocket-id";
        repo = "pocket-id";
        tag = "v${version}";
        hash = "sha256-jvC2m+sksVSn1pMH0tSM+r5W1VZUEHQJKzQT8GPgspI=";
      };
      vendorHash = "sha256-hMhOG/2xnI/adjg8CnA0tRBD8/OFDsTloFXC8iwxlV0=";

      frontend = prev.stdenvNoCC.mkDerivation {
        pname = "pocket-id-frontend";
        inherit version src;
        nativeBuildInputs = [
          prev.nodejs
          prev.pnpmConfigHook
          prev.pnpm_10
        ];
        pnpmDeps = prev.fetchPnpmDeps {
          pname = "pocket-id";
          inherit version src;
          pnpm = prev.pnpm_10;
          hash = "sha256-dIhNxUBt+jxUp5I4cPZ6/PtNSyMTd6xkX6XE2SwD+ok=";
        };
        env.BUILD_OUTPUT_PATH = "dist";
        buildPhase = ''
          runHook preBuild
          pnpm --filter pocket-id-frontend build
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out/lib/pocket-id-frontend
          cp -r frontend/dist $out/lib/pocket-id-frontend/dist
          runHook postInstall
        '';
      };
    });
  };

  # Adds pkgs.stable == inputs.nixpkgs-stable.legacyPackages.${pkgs.system}
  stable = final: _: {
    stable = inputs.nixpkgs-stable.legacyPackages.${final.system};
  };
}
