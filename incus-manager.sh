#! /usr/bin/env nix-shell
#!nix-shell -i bash -p ssh-to-age jq
# shellcheck shell=bash

# --- Configuration & Constants ---

readonly DEFAULT_REMOTE="${INCUS_DEFAULT_REMOTE:-tiny1}"
readonly DEFAULT_NETWORK_DEVICE="${INCUS_NETWORK_DEVICE:-eth0}"
readonly PERSIST_BASE_PATH="${INCUS_PERSIST_PATH:-/persist/microvms}"
readonly CONTAINER_START_WAIT="${INCUS_START_WAIT:-5}"
readonly CONTAINER_RESTART_TIMEOUT="${INCUS_RESTART_TIMEOUT:-30}"

# --- Utility Functions ---

# Error handling
error() {
  echo >&2 "Error: $*"
  return 1
}

fatal() {
  echo >&2 "Error: $*"
  exit 1
}

warn() {
  echo "Warning: $*"
}

# Check for required tools
check_required_tools() {
  local missing_tools=()

  for tool in "$@"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      missing_tools+=("$tool")
    fi
  done

  if [ ${#missing_tools[@]} -gt 0 ]; then
    error "Required tools not installed: ${missing_tools[*]}"
    return 1
  fi

  return 0
}

# Ensure we're on the correct remote
ensure_remote() {
  local remote=$1
  incus remote switch "$remote" || fatal "Failed to switch to remote '$remote'"
}

# Get container's IP address
get_container_ip() {
  local container=$1
  local remote=$2
  local device=${3:-$DEFAULT_NETWORK_DEVICE}

  local ip_address
  ip_address=$(incus list "$container" --format=json | jq -r ".[0].state.network.${device}.addresses[] | select(.family == \"inet\") | .address")

  if [ -z "$ip_address" ] || [ "$ip_address" == "null" ]; then
    error "Could not detect IPv4 address for $container on $device"
    return 1
  fi

  echo "$ip_address"
}

# Parse --remote option from arguments
parse_remote_option() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    --remote)
      echo "$2"
      return
      ;;
    *)
      shift
      ;;
    esac
  done
  echo "$DEFAULT_REMOTE"
}

# Parse --nesting option from arguments
parse_nesting_option() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    --nesting)
      echo "-c security.nesting=true"
      return
      ;;
    *)
      shift
      ;;
    esac
  done
  echo ""
}

# Validate container argument
require_container() {
  local container=$1
  if [ -z "$container" ]; then
    fatal "No container specified."
  fi
  echo "$container"
}

# --- CLI & Help ---

# Prints usage information
usage() {
  echo "Usage: $0 <command> [arguments...] [--remote <remote_name>]"
  echo
  echo "Quick Start:"
  echo "  bootstrap  <container> [--nesting]     Complete container setup (steps 1-6)."
  echo "                                         Then update nix-config and run 'deploy'."
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
  echo "  add-storage <container> <host_path> <container_path> [--uid <uid>]"
  echo "                                         Adds a storage disk mount with optional ID mapping."
  echo "  set-ip     <container> [ip_address]    Sets a static IP. Detects current IP if not provided."
  echo "  get-age-key <container>                Computes the age public key from the container's SSH host key."
  echo
  echo "Options:"
  echo "  --remote <remote>   The Incus remote to use (default: tiny1)."
  echo
  echo "Examples:"
  echo "  # Complete bootstrap for a new container with nesting enabled:"
  echo "  $0 bootstrap immich --nesting"
  echo
  echo "  # Then update .sops.yaml and services/caddy.nix with the displayed info, and:"
  echo "  $0 deploy immich"
  echo
  echo "  # Add storage after deployment:"
  echo "  $0 add-storage immich /mnt/storage/immich /mnt/immich/ --uid 998"
  exit 1
}

# --- Low-level Container Operations ---

build_image() {
  local container=$1
  echo "Building image for $container..."
  nix build ".#nixosConfigurations.$container.config.system.build.metadata" --print-out-paths >/dev/null
  nix build ".#nixosConfigurations.$container.config.system.build.squashfs" --print-out-paths >/dev/null
  echo "Build complete for $container."
}

import_image() {
  local container=$1
  local remote=$2
  echo "Importing image for $container to remote $remote..."
  ensure_remote "$remote"
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
  ensure_remote "$remote"
  incus rebuild "nixos/custom/$container" "$container" --force
}

restart_container() {
  local container=$1
  local remote=$2
  echo "Restarting container $container on remote $remote..."
  ensure_remote "$remote"
  incus restart "$container" --timeout "$CONTAINER_RESTART_TIMEOUT"
}

start_container() {
  local container=$1
  local remote=$2
  echo "Starting container $container on remote $remote..."
  ensure_remote "$remote"
  incus start "$container"

  # Wait a bit for the container to get an IP
  echo "Waiting for container to initialize..."
  sleep "$CONTAINER_START_WAIT"
}

create_container() {
  local container=$1
  local remote=$2
  local nesting_arg=$3
  echo "Creating container $container on remote $remote..."
  ensure_remote "$remote"
  # shellcheck disable=SC2086
  incus create "nixos/custom/$container" "$container" $nesting_arg
}

create_persist_dir() {
  local container=$1
  local remote=$2
  echo "Creating persist directory on remote $remote..."

  # Try to create the directory via SSH
  # shellcheck disable=SC2029
  if ssh -t "$remote" "sudo mkdir -p $PERSIST_BASE_PATH/$container" 2>/dev/null; then
    echo "Persist directory created successfully."
  else
    warn "Could not create persist directory via SSH."
    echo "You may need to manually run on $remote:"
    echo "  sudo mkdir -p $PERSIST_BASE_PATH/$container"
  fi
}

add_persist_disk() {
  local container=$1
  local remote=$2
  echo "Adding persist disk to $container on remote $remote..."
  ensure_remote "$remote"
  incus config device add "$container" persist disk "source=$PERSIST_BASE_PATH/$container" "path=/persist" "shift=true"
}

set_ip() {
  local container=$1
  local remote=$2
  local ip_address=$3
  local device=${4:-$DEFAULT_NETWORK_DEVICE}

  ensure_remote "$remote"

  if [ -z "$ip_address" ]; then
    echo "IP address not provided. Detecting current IP for $container..."
    ip_address=$(get_container_ip "$container" "$remote" "$device") || fatal "Could not detect IPv4 address for $container. Please ensure the container is running and has a network lease."
    echo "Detected IP: $ip_address"
  fi

  echo "Setting static IP $ip_address on $device for container $container..."
  incus config device override "$container" "$device" "ipv4.address=$ip_address"
}

get_age_key() {
  local container=$1
  local remote=$2

  ensure_remote "$remote"

  echo "Computing age key for $container from remote $remote..."
  incus exec "$container" -- cat "/persist/etc/ssh/ssh_host_ed25519_key.pub" | ssh-to-age
}

add_storage() {
  local container=$1
  local remote=$2
  local host_path=$3
  local container_path=$4
  local uid=$5

  echo "Adding storage disk to $container on remote $remote..."
  ensure_remote "$remote"

  local device_name
  device_name=$(basename "$host_path")

  # Check if device already exists
  if incus config device show "$container" | grep -q "^${device_name}:"; then
    fatal "Device '$device_name' already exists on container $container. Please remove the existing device first or use a different path."
  fi

  if [ -n "$uid" ]; then
    echo "Configuring with ID mapping for UID $uid..."
    incus config device add "$container" "$device_name" disk \
      source="$host_path" \
      path="$container_path" \
      raw.mount.options="idmap=b:${uid}:0:1"

    incus config set "$container" raw.idmap "both 0 ${uid}"
  else
    echo "Adding storage without ID mapping..."
    incus config device add "$container" "$device_name" disk \
      source="$host_path" \
      path="$container_path"
  fi

  echo "Storage device '$device_name' added successfully."
}

# --- Composite Operations ---

validate_bootstrap() {
  local container=$1
  local remote=$2

  # Check if required tools are available
  check_required_tools jq ssh-to-age || return 1

  # Check if container config exists
  if ! nix eval --raw ".#nixosConfigurations.$container.config.system.nixos.version" 2>/dev/null >/dev/null; then
    error "Container configuration '$container' not found in flake. Make sure containers/$container.nix exists." || return 1
  fi

  # Check if remote is accessible
  if ! incus remote list | grep -q "^| $remote "; then
    error "Remote '$remote' not configured in Incus." || return 1
  fi

  return 0
}

print_bootstrap_summary() {
  local container=$1
  local ip_address=$2
  local age_key=$3

  echo
  echo "╔════════════════════════════════════════════════════════════════════════╗"
  echo "║ Container Bootstrap Complete: $(printf '%-40s' "$container")║"
  echo "╠════════════════════════════════════════════════════════════════════════╣"
  echo "║ IP Address:  $(printf '%-57s' "$ip_address")║"
  echo "║ Age Key:     $(printf '%-57s' "${age_key:0:57}")║"
  if [ ${#age_key} -gt 57 ]; then
    echo "║              $(printf '%-57s' "${age_key:57}")║"
  fi
  echo "╠════════════════════════════════════════════════════════════════════════╣"
  echo "║ Next Steps:                                                            ║"
  echo "║                                                                        ║"
  echo "║ 1. Add age key to .sops.yaml under the 'hosts:' section:              ║"
  echo "║    - &lxc-$container $(printf '%-52s' "$age_key")║" | head -c 76
  echo "║"
  echo "║                                                                        ║"
  echo "║ 2. Add a creation_rules entry for containers/secrets/$container.yaml  ║"
  echo "║    (copy an existing container's entry as template)                   ║"
  echo "║                                                                        ║"
  echo "║ 3. If container needs reverse proxy, add to services/caddy.nix:       ║"
  echo "║    reverse_proxy http://${ip_address}:<port>                          ║"
  echo "║                                                                        ║"
  echo "║ 4. Deploy the configuration:                                          ║"
  echo "║    ./incus-manager.sh deploy $container                               ║"
  echo "║                                                                        ║"
  echo "║ 5. Add storage if needed:                                             ║"
  echo "║    ./incus-manager.sh add-storage $container \\                        ║"
  echo "║      /mnt/storage/$container /mnt/$container/ --uid <uid>             ║"
  echo "╚════════════════════════════════════════════════════════════════════════╝"
  echo
}

bootstrap_container() {
  local container=$1
  local remote=$2
  local nesting_arg=$3

  echo "=== Starting Bootstrap for $container on remote $remote ==="
  echo

  # Step 0: Validate
  echo "Step 0/8: Validating configuration..."
  if ! validate_bootstrap "$container" "$remote"; then
    echo "Bootstrap validation failed. Aborting."
    exit 1
  fi
  echo "✓ Validation passed"
  echo

  # Step 1: Build
  echo "Step 1/8: Building image..."
  build_image "$container" || {
    echo "Build failed. Aborting."
    exit 1
  }
  echo "✓ Build complete"
  echo

  # Step 2: Import
  echo "Step 2/8: Importing image to remote..."
  import_image "$container" "$remote" || {
    echo "Import failed. Aborting."
    exit 1
  }
  echo "✓ Import complete"
  echo

  # Step 3: Create persist directory
  echo "Step 3/8: Creating persist directory..."
  create_persist_dir "$container" "$remote"
  echo "✓ Persist directory ready"
  echo

  # Step 4: Create container
  echo "Step 4/8: Creating container..."
  create_container "$container" "$remote" "$nesting_arg" || {
    echo "Container creation failed. Aborting."
    exit 1
  }
  echo "✓ Container created"
  echo

  # Step 5: Add persist disk
  echo "Step 5/8: Adding persist disk..."
  add_persist_disk "$container" "$remote" || {
    echo "Adding persist disk failed. Aborting."
    exit 1
  }
  echo "✓ Persist disk added"
  echo

  # Step 6: Start container
  echo "Step 6/8: Starting container..."
  start_container "$container" "$remote" || {
    echo "Starting container failed. Aborting."
    exit 1
  }
  echo "✓ Container started"
  echo

  # Step 7: Set static IP
  echo "Step 7/8: Setting static IP..."
  set_ip "$container" "$remote" "" || {
    echo "Setting IP failed. Aborting."
    exit 1
  }
  echo "✓ Static IP configured"
  echo

  # Step 8: Get age key
  echo "Step 8/8: Computing age key..."
  local age_key
  age_key=$(get_age_key "$container" "$remote") || {
    echo "Getting age key failed. Aborting."
    exit 1
  }
  echo "✓ Age key computed"
  echo

  # Get the IP address for the summary
  local ip_address
  ip_address=$(get_container_ip "$container" "$remote") || fatal "Failed to get container IP"

  # Print summary
  print_bootstrap_summary "$container" "$ip_address" "$age_key"
}

# --- Main CLI Logic ---

if [[ $# -lt 1 ]]; then
  usage
fi

COMMAND=$1
shift
REMOTE="$DEFAULT_REMOTE"

case "$COMMAND" in
build | import | rebuild | restart | deploy)
  CONTAINERS=$(require_container "$1")
  shift
  REMOTE=$(parse_remote_option "$@")

  for container in ${CONTAINERS//,/ }; do
    echo "--- Processing container: $container ---"
    case "$COMMAND" in
    build) build_image "$container" ;;
    import) import_image "$container" "$REMOTE" ;;
    rebuild) rebuild_container "$container" "$REMOTE" ;;
    restart) restart_container "$container" "$REMOTE" ;;
    deploy)
      import_image "$container" "$REMOTE" &&
        rebuild_container "$container" "$REMOTE" &&
        restart_container "$container" "$REMOTE"
      ;;
    esac
    echo "--- Finished processing $container ---"
  done
  ;;

bootstrap | create)
  CONTAINER=$(require_container "$1")
  shift
  NESTING_ARG=$(parse_nesting_option "$@")
  REMOTE=$(parse_remote_option "$@")

  if [ "$COMMAND" == "bootstrap" ]; then
    bootstrap_container "$CONTAINER" "$REMOTE" "$NESTING_ARG"
  else
    create_container "$CONTAINER" "$REMOTE" "$NESTING_ARG"
  fi
  ;;

add-persist-disk | get-age-key)
  CONTAINER=$(require_container "$1")
  shift
  REMOTE=$(parse_remote_option "$@")

  case "$COMMAND" in
  add-persist-disk) add_persist_disk "$CONTAINER" "$REMOTE" ;;
  get-age-key) get_age_key "$CONTAINER" "$REMOTE" ;;
  esac
  ;;

set-ip)
  CONTAINER=$(require_container "$1")
  shift
  IP_ADDRESS=""
  if [ -n "$1" ] && [[ ! $1 =~ ^-- ]]; then
    IP_ADDRESS=$1
    shift
  fi
  REMOTE=$(parse_remote_option "$@")
  set_ip "$CONTAINER" "$REMOTE" "$IP_ADDRESS"
  ;;

add-storage)
  CONTAINER=$(require_container "$1")
  shift
  HOST_PATH=$1
  shift
  CONTAINER_PATH=$1
  shift
  _UID=""

  while [[ $# -gt 0 ]]; do
    case $1 in
    --uid)
      _UID="$2"
      shift 2
      ;;
    --remote)
      REMOTE="$2"
      shift 2
      ;;
    *)
      fatal "Unknown option: $1"
      ;;
    esac
  done

  if [ -z "$HOST_PATH" ] || [ -z "$CONTAINER_PATH" ]; then
    fatal "Host path and container path are required."
  fi

  add_storage "$CONTAINER" "${REMOTE:-$DEFAULT_REMOTE}" "$HOST_PATH" "$CONTAINER_PATH" "$_UID"
  ;;

*)
  echo "Invalid command: $COMMAND"
  usage
  ;;
esac

echo "All tasks completed."
