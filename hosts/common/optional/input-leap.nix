{pkgs, ...}: {
  # https://github.com/NixOS/nixpkgs/pull/341425
  environment.systemPackages = [pkgs.input-leap];
  networking.firewall.allowedTCPPorts = [24800];
}
