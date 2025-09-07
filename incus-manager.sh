#! /usr/bin/env nix-shell
#!nix-shell -i bash -p ssh-to-age

# --- Helper functions ---

# Prints usage information
usage() {
    echo "Usage: $0 <command> [arguments...] [--remote <remote_name>]"
    echo
    echo "Deployment Commands (support comma-separated list of containers):"
    echo "  build      <containers>                Builds the container image(s)."
    echo "  import     <containers>                Imports the built image(s) into Incus."
    echo "  rebuild    <containers>                Rebuilds the container(s) on the remote."
    echo "  restart    <containers>                Restarts the container(s)."
    echo "  deploy     <containers>                Performs import, rebuild, and restart for container(s)."
    echo
    echo "Setup Commands (operate on a single container):"
    echo "  create     <container> [--nesting]     Creates a new container from a nixos/custom/<container> image."
    echo "  add-persist-disk <container>           Adds a standard persist disk for the container."
    echo "  set-ip     <container> [ip_address]    Sets a static IP. Detects current IP if not provided."
    echo "  get-age-key <container>                Computes the age public key from the container's SSH host key."
    echo
    echo "Options:"
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

# --- Setup functions ---

create_container() {
    local container=$1
    local remote=$2
    local nesting_arg=$3
    echo "Creating container $container on remote $remote..."
    incus remote switch "$remote"
    # shellcheck disable=SC2086
    incus create "nixos/custom/$container" "$container" $nesting_arg
}

# TODO: requires sudo mkdir /persist/microvms/<container> on the remote first
add_persist_disk() {
    local container=$1
    local remote=$2
    echo "Adding persist disk to $container on remote $remote..."
    incus remote switch "$remote"
    incus config device add "$container" persist disk "source=/persist/microvms/$container" "path=/persist" "shift=true"
}

set_ip() {
    local container=$1
    local remote=$2
    local ip_address=$3
    local device=${4:-eth0}

    incus remote switch "$remote"

    if [ -z "$ip_address" ]; then
        command -v jq >/dev/null 2>&1 || { echo >&2 "jq is required for IP detection but it's not installed. Aborting."; exit 1; }
        echo "IP address not provided. Detecting current IP for $container..."
        ip_address=$(incus list "$container" --format=json | jq -r ".[] | .state.network.${device}.addresses[] | select(.family == \"inet\") | .address")
        if [ -z "$ip_address" ] || [ "$ip_address" == "null" ]; then
            echo "Error: Could not detect an IPv4 address for $container."
            echo "Please ensure the container is running and has a network lease."
            exit 1
        fi
        echo "Detected IP: $ip_address"
    fi

    echo "Setting static IP $ip_address on $device for container $container..."
    incus config device override "$container" "$device" "ipv4.address=$ip_address"
}

get_age_key() {
    local container=$1
    local remote=$2

    incus remote switch "$remote"

    command -v ssh-to-age >/dev/null 2>&1 || { echo >&2 "ssh-to-age is required but it's not installed. Aborting."; exit 1; }
    echo "Computing age key for $container from remote $remote..."
    incus exec "$container" -- cat "/persist/etc/ssh/ssh_host_ed25519_key.pub" | ssh-to-age
}

# --- Main logic ---

if [[ $# -lt 1 ]]; then
    usage
fi

COMMAND=$1
shift
REMOTE="tiny1" # Default remote

case "$COMMAND" in
    build|import|rebuild|restart|deploy)
        CONTAINERS=$1
        shift
        # Parse options
        while [[ $# -gt 0 ]]; do case $1 in --remote) REMOTE="$2"; shift 2;; *) echo "Unknown option: $1"; usage;; esac; done
        if [ -z "$CONTAINERS" ]; then echo "No containers specified."; usage; fi

        for container in ${CONTAINERS//,/ }; do
            echo "--- Processing container: $container ---"
            case "$COMMAND" in
                build) build_image "$container";;
                import) import_image "$container" "$REMOTE";;
                rebuild) rebuild_container "$container" "$REMOTE";;
                restart) restart_container "$container" "$REMOTE";;
                deploy)
                    import_image "$container" "$REMOTE" && \
                    rebuild_container "$container" "$REMOTE" && \
                    restart_container "$container" "$REMOTE"
                    ;;
            esac
            echo "--- Finished processing $container ---"
        done
        ;;

    create)
        CONTAINER=$1; shift
        NESTING_ARG=""
        if [[ "$1" == "--nesting" ]]; then NESTING_ARG="-c security.nesting=true"; shift; fi
        while [[ $# -gt 0 ]]; do case $1 in --remote) REMOTE="$2"; shift 2;; *) echo "Unknown option: $1"; usage;; esac; done
        if [ -z "$CONTAINER" ]; then echo "No container specified."; usage; fi
        create_container "$CONTAINER" "$REMOTE" "$NESTING_ARG"
        ;;

    add-persist-disk)
        CONTAINER=$1; shift
        while [[ $# -gt 0 ]]; do case $1 in --remote) REMOTE="$2"; shift 2;; *) echo "Unknown option: $1"; usage;; esac; done
        if [ -z "$CONTAINER" ]; then echo "No container specified."; usage; fi
        add_persist_disk "$CONTAINER" "$REMOTE"
        ;;

    set-ip)
        CONTAINER=$1; shift; IP_ADDRESS=$1; shift
        while [[ $# -gt 0 ]]; do case $1 in --remote) REMOTE="$2"; shift 2;; *) echo "Unknown option: $1"; usage;; esac; done
        if [ -z "$CONTAINER" ]; then echo "No container specified."; usage; fi
        set_ip "$CONTAINER" "$REMOTE" "$IP_ADDRESS"
        ;;

    get-age-key)
        CONTAINER=$1; shift
        while [[ $# -gt 0 ]]; do case $1 in --remote) REMOTE="$2"; shift 2;; *) echo "Unknown option: $1"; usage;; esac; done
        if [ -z "$CONTAINER" ]; then echo "No container specified."; usage; fi
        get_age_key "$CONTAINER" "$REMOTE"
        ;;

    *)
        echo "Invalid command: $COMMAND"
        usage
        ;;
esac

echo "All tasks completed."
