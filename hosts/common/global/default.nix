# This file (and the global directory) holds config that i use on all hosts
{
  inputs,
  outputs,
  ...
}: {
  imports =
    [
      inputs.home-manager.nixosModules.home-manager
      ./catppuccin.nix
      ./locale.nix
      #./nameservers.nix
      ./nix.nix
      ./nixpkgs.nix
      ./openssh.nix
      ./sops.nix
      ./tailscale.nix
      ./zsh.nix
    ]
    ++ (builtins.attrValues outputs.nixosModules);

  home-manager.useGlobalPkgs = true;
  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
  };

  hardware.enableRedistributableFirmware = true;
}
