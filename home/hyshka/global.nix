{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}:
let
  isLinux = pkgs.stdenv.isLinux;
in
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ]
  ++ (builtins.attrValues outputs.homeManagerModules);

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      warn-dirty = false;
    };
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
  };

  # shell show which Nix package (if any) provides a missing command
  programs.command-not-found = {
    enable = true;
    dbPath = "${inputs.nixpkgs}/programs.sqlite";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = lib.mkIf isLinux "sd-switch";

  # Enable home-manager
  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "hyshka";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
  };

  catppuccin = {
    enable = true;
    flavor = "frappe";
  };
}
