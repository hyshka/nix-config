{
  outputs,
  pkgs,
  ...
}: {
  imports = [
    ../../home/cli
    ../../home/nixvim
    ../../home/hyshka/features/alacritty.nix
    ./aerospace.nix
  ];

  nixpkgs = {
    overlays = [
      #outputs.overlays.additions
      outputs.overlays.modifications
      #outputs.overlays.stable
    ];
  };

  home = {
    username = "hyshka";
    homeDirectory = "/Users/hyshka";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # images
    gimp

    # coding
    pre-commit
    python310Packages.nodeenv # for node.js pre-commit hooks
    # TODO aws cli
    #awscli2
    # TODO mrcli
    lorri # statoscope
  ];

  # Enable home-manager
  programs = {
    home-manager.enable = true;
    git.enable = true; # always a requirement for home-manager
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
