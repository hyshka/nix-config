# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # Use llm-agents version of opencode instead of nixpkgs
    opencode = inputs.llm-agents.packages.${prev.stdenv.hostPlatform.system}.opencode;

    # Pin Incus to version 6.17.0
    incus = inputs.nixpkgs-incus-6-18.legacyPackages.${prev.stdenv.hostPlatform.system}.incus;

    sunshine = prev.sunshine.overrideAttrs (_oldAttrs: {
      extraLibraries = [
        prev.util-linux # required for setsid
      ];
    });

    # Temporary fix: https://github.com/NixOS/nixpkgs/pull/564140/
    tree-sitter-grammars = prev.tree-sitter-grammars.overrideScope (
      _grammarFinal: grammarPrev: {
        tree-sitter-cuda = grammarPrev.tree-sitter-cuda.overrideAttrs (_oldAttrs: {
          src = final.fetchFromGitHub {
            owner = "tree-sitter-grammars";
            repo = "tree-sitter-cuda";
            rev = "v0.21.2";
            hash = "sha256-s2qrZx5fEu/I6xE2paX/Nlmgvo6T27qqvy1cI8iznAA=";
          };
        });
      }
    );
  };

  # Adds pkgs.stable == inputs.nixpkgs-stable.legacyPackages.${pkgs.system}
  stable = final: _: {
    stable = inputs.nixpkgs-stable.legacyPackages.${final.system};
  };
}
