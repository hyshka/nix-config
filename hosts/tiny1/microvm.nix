# https://github.com/Soikr/microvm-examples/blob/main/vms/default.nix
{
  self,
  inputs,
  ...
}: {
  imports = [
    inputs.microvm.nixosModules.host
    ./microvm-networking.nix
  ];

  microvm = {
    vms = {
      microvm = {
        flake = self;
        updateFlake = "git+file:///home/hyshka/nix-config";
      };
    };
    autostart = [
      "microvm"
    ];
  };
}
