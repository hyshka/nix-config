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
    NIXOS_BUILD_ID=$(nix eval --raw ".#nixosConfigurations.$container.config.system.nixos.version")
    incus image import --alias nixos/custom/$container --reuse \
    $(nix build ".#nixosConfigurations.$container.config.system.build.metadata" --print-out-paths)/tarball/nixos-image-lxc-${NIXOS_BUILD_ID}-x86_64-linux.tar.xz \
    $(nix build ".#nixosConfigurations.$container.config.system.build.squashfs" --print-out-paths)/nixos-lxc-image-x86_64-linux.squashfs

    incus rebuild nixos/custom/$container $container --force
    incus restart $container
done
