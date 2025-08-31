#!/usr/bin/env bash

# --- Helper functions ---

# Prints usage information
usage() {
    echo "Usage: $0 <command> <containers> [--remote <remote_name>]"
    echo
    echo "Commands:"
    echo "  build      Builds the container image(s)."
    echo "  import     Imports the built image(s) into Incus."
    echo "  rebuild    Rebuilds the container(s) on the remote."
    echo "  restart    Restarts the container(s)."
    echo "  deploy     Performs import, rebuild, and restart for container(s)."
    echo
    echo "Arguments:"
    echo "  <containers>        A comma-separated list of container names."
    echo "  --remote <remote>   The Incus remote to use (default: tiny1)."
    exit 1
}

# --- Core functions for each step ---

build_image() {
    local container=$1
    echo "Building image for $container..."
    nix build ".#nixosConfigurations.$container.config.system.build.metadata" --print-out-paths > /dev/null
    nix build ".#nixosConfigurations.$container.config.system.build.squashfs" --print-out-paths > /dev/null
    echo "Build complete for $container."
}

import_image() {
    local container=$1
    local remote=$2
    echo "Importing image for $container to remote $remote..."
    incus remote switch "$remote"
    local NIXOS_BUILD_ID
    NIXOS_BUILD_ID=$(nix eval --raw ".#nixosConfigurations.$container.config.system.nixos.version")
    local tarball_path
    tarball_path=$(nix build ".#nixosConfigurations.$container.config.system.build.metadata" --print-out-paths)/tarball/nixos-image-lxc-${NIXOS_BUILD_ID}-x86_64-linux.tar.xz
    local squashfs_path
    squashfs_path=$(nix build ".#nixosConfigurations.$container.config.system.build.squashfs" --print-out-paths)/nixos-lxc-image-x86_64-linux.squashfs

    incus image import --alias "nixos/custom/$container" --reuse "$tarball_path" "$squashfs_path"
}

rebuild_container() {
    local container=$1
    local remote=$2
    echo "Rebuilding container $container on remote $remote..."
    incus remote switch "$remote"
    incus rebuild "nixos/custom/$container" "$container" --force
}

restart_container() {
    local container=$1
    local remote=$2
    echo "Restarting container $container on remote $remote..."
    incus remote switch "$remote"
    incus restart "$container"
}

# --- Main logic ---

if [[ $# -lt 2 ]]; then
    usage
fi

COMMAND=$1
shift
CONTAINERS=$1
shift
REMOTE="tiny1" # Default remote

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        --remote)
            REMOTE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [ -z "$CONTAINERS" ]; then
    echo "No containers specified."
    usage
fi

# Execute command for each container
for container in ${CONTAINERS//,/ }; do
    echo "--- Processing container: $container ---"
    case "$COMMAND" in
        build)
            build_image "$container"
            ;;
        import)
            import_image "$container" "$REMOTE"
            ;;
        rebuild)
            rebuild_container "$container" "$REMOTE"
            ;;
        restart)
            restart_container "$container" "$REMOTE"
            ;;
        deploy)
            import_image "$container" "$REMOTE" && \
            rebuild_container "$container" "$REMOTE" && \
            restart_container "$container" "$REMOTE"
            ;;
        *)
            echo "Invalid command: $COMMAND"
            usage
            ;;
    esac
    echo "--- Finished processing $container ---"
done

echo "All tasks completed."
