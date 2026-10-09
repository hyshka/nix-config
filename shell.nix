# Shell for bootstrapping flake-enabled nix and other tooling
{
  pkgs ?
    # If pkgs is not defined, instanciate nixpkgs from locked commit
    let
      lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
      nixpkgs = fetchTarball {
        url = lock.url;
        sha256 = lock.narHash;
      };
    in
    import nixpkgs { overlays = [ ]; },
}:
pkgs.mkShell {
  NIX_CONFIG = "extra-experimental-features = nix-command flakes";
  packages =
    with pkgs;
    [
      nix
      nh
      dix
      nixos-rebuild
      home-manager
      git

      # infra
      opentofu
      sshfs # incus file mount

      # sops-nix secrets workflow
      sops
      ssh-to-age
      age
      gnupg
      pinentry-curses

      # deploy.sh and incus-manager.sh
      jq
    ]
    # incus client is linux-only; keep the darwin devShell buildable
    ++ lib.optionals stdenv.hostPlatform.isLinux [ incus ];
}
