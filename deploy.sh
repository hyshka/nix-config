#!/usr/bin/env bash
export NIX_SSHOPTS="-A"

hosts="$1"
shift

if [ -z "$hosts" ]; then
  echo "No hosts to deploy"
  exit 2
fi

for host in ${hosts//,/ }; do
  nixos-rebuild --flake ".#$host" switch --target-host "root@$host" "$@"
done
