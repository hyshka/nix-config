# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  ...
}: {
  # You can import other home-manager modules here
  imports =
    [
      # If you want to use home-manager modules from other flakes:
      #inputs.zimfw.homeManagerModules.zimfw
      inputs.sops-nix.homeManagerModule
      inputs.nixvim.homeManagerModules.nixvim
      inputs.catppuccin.homeManagerModules.catppuccin

      # You can also split up your configuration and import pieces of it here:
      ./cli
      #./nvim
      ./nixvim
      ./desktop
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    # TODO I don't know why this also needs to be set for home-manager
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  catppuccin = {
    enable = true;
    flavor = "frappe";
  };

  home = {
    username = "hyshka";
    homeDirectory = "/home/hyshka";
  };

  # Enable home-manager
  programs = {
    home-manager.enable = true;
    git.enable = true; # always a requirement for home-manager
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
