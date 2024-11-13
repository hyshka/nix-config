#!/bin/bash

# Make users and group
# This is all managed in configuration.nix
#
# sudo nixos-rebuild switch

# Make subvolumes
# sudo btrfs subvolume create /mnt/storage/mediacenter/

# Mount subvolumes
# This is all managed in configuration.nix
#
# sudo nixos-rebuild switch

# Make directories
cd ~/media
mkdir -pv ./{sonarr,radarr,qbittorrent,prowlarr,wireguard,jellyfin,recyclarr,jellyseer,sabnzbd}-config
sudo mkdir -pv /mnt/storage/mediacenter/{torrents,media}/{tv,movies}

# Copy configs
# cp wg0.conf ./wireguard-config/

# Set permissions
sudo chmod -R 775 /mnt/storage/mediacenter
sudo chown -R $(id -u):mediacenter /mnt/storage/mediacenter
sudo chown -R sonarr:mediacenter ./sonarr-config
sudo chown -R radarr:mediacenter ./radarr-config
sudo chown -R jellyfin:mediacenter ./jellyfin-config
sudo chown -R qbittorrent:mediacenter ./qbittorrent-config
sudo chown -R wireguard:mediacenter ./wireguard-config
sudo chown -R recyclarr:mediacenter ./recyclarr-config
sudo chown -R jellyseer:mediacenter ./jellyseer-config
sudo chown -R prowlarr:mediacenter ./prowlarr-config
sudo chown -R sabnzbd:mediacenter ./sabnzbd-config

# Recyclarr config
# docker compose run --rm recyclarr config create
