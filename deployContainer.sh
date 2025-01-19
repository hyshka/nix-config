#!/usr/bin/env bash
containers="$1"
shift

if [ -z "$containers" ]; then
    echo "No containers to build"
    exit 2
fi

# TODO: I only have one remote, but I could add the host as a param to the script
incus remote switch tiny1

for container in ${containers//,/ }; do
    incus image import --alias nixos/custom/$container \
    $(nix build ".#nixosConfigurations.$container.config.system.build.metadata" --print-out-paths)/tarball/nixos-image-lxc-25.05.20250102.6df2492-x86_64-linux.tar.xz \
    $(nix build ".#nixosConfigurations.$container.config.system.build.squashfs" --print-out-paths)/nixos-lxc-image-x86_64-linux.squashfs
done
