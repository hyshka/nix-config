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
  packages = with pkgs; [
    nix
    nh
    dix
    nixos-rebuild
    home-manager
    git
    prek # git hooks; config in prek.toml

    # infra
    opentofu
    sshfs # incus file mount
    incus

    # sops-nix secrets workflow
    sops
    ssh-to-age
    age
    gnupg
    pinentry-curses

    # deploy.sh
    jq
  ];

  # prek installs its shims on every shell entry. A global core.hooksPath makes
  # prek refuse; that case is silent here, rerun the command manually with --force.
  shellHook = ''
    prek install -q --allow-missing-config 2>/dev/null || true
  '';
}
