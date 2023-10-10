## Pre-launch

- [x] Move secrets into nix config
- [x] Move homepage configs into nix config
- [x] Disable psitransfer
- [x] Copy ntfy auth file to new server, or nix config if possible
  - /var/lib/ntfy-sh/user.db
  - chown ntfy-sh:ntfy-sh /var/lib/ntfy-sh/user.db
  - chmod 600 /var/lib/ntfy-sh/user.db
- [x] Copy syncthing key + cert to new server, or nix config if possible
  - Ensure there are no changes not added to the nix config
  - Ensure there are no other files I need to move
- [x] Prep media server
  - [x] Update docker images to current
  - [ ] Copy wireguard keys to new server or nix config?
    - wireguard-keys maps to punctual llama device in Mullvad
      - these appear to be unused
    - however, wg0 is using busy pony private key
    - key will be moved when moving media configs
- [x] Anything else required for snapraid/mergerfs?
  - not for mergerfs, it's purely FS level
  - just need to copy the content file from rpi4 root
- [x] Copy new secrets from rpi4 to tiny1
- [x] Copy rpi4 services to tiny1, including hardware config

## Launch (at least 1 hour)

1. [ ] Run snapraid sync on rpi4 (skipped this since I didn't want to mess with syncthing either)
2. [x] Ensure Syncthing is fully up to date on rpi4
3. [x] Disable all services on rpi4 and tiny1
4. [x] Copy /var/snapraid.content from rpi4 to tiny1
5. [x] Copy ~/.config/syncthing from rpi4 to tiny1
6. [x] Copy ~/media from rpi4 to tiny1
   - sudo chmod 600 <keys>
7. [x] chown ntfy-sh:ntfy-sh /var/lib/ntfy-sh/user.db (user must exist)
8. [x] Power off both servers
9. [x] Move all drives from rip4 to tiny1
10. [ ] Power on tiny1 (already on)
11. [x] Enable filesystem configs for mergerfs and snapraid
    - fix filesystem owners and groups
12. [x] Enable /mnt/storage Samba share
13. [x] Enable services one-by-one on tiny1
14. [ ] Run snapraid sync on tiny1 (let it run overnight)

## Post-launch

- [ ] Verify tiny1Ex and starshipEx through ssh
- [ ] Update flake and rebuild all hosts
- [ ] Backup btrfs corrupted files lists in ~/ and burn-in logs
- [ ] Backup wireguard-keys
- [ ] Backup homepage-conf
- [ ] Move media server configs into nix config
