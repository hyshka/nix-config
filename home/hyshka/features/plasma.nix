{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  home.packages = with pkgs; [
    kdePackages.krohnkite
    kwin6-bismuth-decoration
  ];

  # TODO plasma-manager
  # https://github.com/nix-community/plasma-manager
  # TODO krohnkite key binds
  # https://github.com/phrmendes/dotfiles/blob/0deb7f64e88c165e2a3db8bdf7491dc45209c8d6/modules/plasma.nix#L4
  # https://github.com/f-koehler/nix-configs/blob/3f346f598c5dab55cdb6fc42a067c705fb91ec9b/home/modules/plasma.nix#L8
}
