# VPN Gateway Architecture

## Overview

The `wireguard-gateway` and `media-download` containers work together to provide anonymous downloading through a WireGuard VPN tunnel to ProtonVPN. This architecture routes all download traffic (BitTorrent and Usenet) through the VPN while keeping management and web UI access local for simplicity.

### Components

- **wireguard-gateway** (10.100.0.2): VPN gateway providing WireGuard tunnel, NAT, and DNS forwarding
- **media-download** (10.100.0.3): Download client running qBittorrent and SABnzbd
- **vpnbr0**: Incus bridge network (10.100.0.0/24) connecting the containers

### Design Goals

- **Practical simplicity**: Keep networking as simple as possible while maintaining security
- **VPN kill switch**: All internet traffic fails if VPN goes down (no fallback)
- **No DNS leaks**: All DNS queries go through ProtonVPN DNS (10.2.0.1)
- **Direct access**: Web UIs accessible via direct IP (no complex port forwarding)

---

## Network Architecture

### Topology Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ Incus Host (tiny1)                                          │
│                                                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ vpnbr0 Network (10.100.0.0/24)                         │ │
│  │                                                        │ │
│  │  ┌──────────────────┐          ┌──────────────────┐    │ │
│  │  │ wireguard-       │   eth1   │ media-download   │    │ │
│  │  │ gateway          │◄────────►│ (10.100.0.3)     │    │ │
│  │  │ (10.100.0.2)     │  LOCAL   │                  │    │ │
│  │  │                  │          │ qBittorrent:8080 │    │ │
│  │  │ ┌──────────────┐ │          │ SABnzbd:8085     │    │ │
│  │  │ │ wg0 (VPN)    │ │          └──────────────────┘    │ │
│  │  │ │ 10.2.0.2     │ │                                  │ │
│  │  │ └──────┬───────┘ │                                  │ │
│  │  └────────┼─────────┘                                  │ │
│  └───────────┼────────────────────────────────────────────┘ │
│              │                                              │
│              │ Encrypted WireGuard Tunnel                   │
│              ▼                                              │
│       ┌──────────────┐                                      │
│       │ ProtonVPN NL │                                      │
│       │ 169.150...   │                                      │
│       └──────┬───────┘                                      │
│              │                                              │
└──────────────┼──────────────────────────────────────────────┘
               │
               ▼
          Internet

Traffic Flow Legend:
→  Local traffic (DNS, ping, web UIs): eth1 (stays in vpnbr0)
⇒  Internet traffic (downloads): eth1 → wg0 → ProtonVPN → Internet
↺  WireGuard handshakes: Direct to 169.150.196.69 (bypass VPN routing)
```

---

## How It Works

### Traffic Flow

#### Local Traffic (DNS queries, web UI access)

1. media-download (10.100.0.3) → wireguard-gateway (10.100.0.2)
2. Routing policy rule (Priority 5): Destination 10.100.0.0/24 → use main table
3. Main table has: 10.100.0.0/24 dev eth1 → stays local
4. Packets delivered via eth1 (vpnbr0 bridge)

**Why this matters**: Without the Priority 5 rule, local traffic would be sent through the VPN tunnel, creating a routing black hole.

#### Internet Traffic (downloads, torrent connections)

1. media-download (10.100.0.3) → wireguard-gateway (10.100.0.2) via eth1
2. Gateway NATs: Source IP changed from 10.100.0.3 → 10.2.0.2 (VPN IP)
3. Routing policy rule (Priority 10): Packet has no fwmark → use table 1000
4. Table 1000: default dev wg0 → VPN tunnel
5. WireGuard encrypts packet → sends to ProtonVPN endpoint (169.150.196.69:51820)
6. ProtonVPN NATs: 10.2.0.2 → ProtonVPN public IP → internet
7. Responses follow reverse path

**Result**: External peers see only ProtonVPN's public IP, never your home ISP IP.

#### WireGuard Handshakes (prevent routing loop)

1. WireGuard marks its own protocol packets with firewall mark 0x8888
2. Routing policy rule (Priority 10): Traffic WITH fwmark → skip table 1000
3. Falls through to main table (Priority 32766)
4. Main table has direct route to 169.150.196.69 via default gateway

**Why this matters**: Without the firewall mark, WireGuard packets would be routed through the WireGuard tunnel itself, creating an infinite loop.

### DNS Resolution

1. media-download queries 127.0.0.53 (local systemd-resolved)
2. systemd-resolved forwards to configured DNS: 10.100.0.2 (wireguard-gateway)
3. wireguard-gateway's systemd-resolved receives query on 10.100.0.2:53
4. Gateway forwards query to 10.2.0.1 (ProtonVPN DNS) through wg0
5. Response returns through VPN → gateway → media-download

**Security**: DNS queries never leave the VPN tunnel. If VPN is down, DNS fails completely (no fallback to public DNS).

### Routing Policy Rules (Priority Order)

Evaluated in order from lowest to highest priority number:

1. **Priority 5**: `To: 10.100.0.0/24 → Table: main`
   - Keeps local subnet traffic local (DNS, web UIs, ping)
   - Prevents routing black hole for inter-container communication

2. **Priority 6**: `To: 169.150.196.69/32 → Table: main`
   - VPN endpoint bypass
   - Ensures WireGuard handshake packets don't route through the tunnel

3. **Priority 10**: `NOT fwmark 0x8888 → Table: 1000`
   - Everything else without firewall mark goes to VPN
   - Applies to all internet-bound traffic from media-download

4. **Priority 32766**: Default fallback to main routing table

---

## Accessing Services

### Web UIs

- **qBittorrent**: `http://10.100.0.3:8080`
- **SABnzbd**: `http://10.100.0.3:8085`

**Access from**:
- Host (tiny1): Direct access via IP
- Desktop (same LAN): Direct access if routable to host's network
- Remote: Use SSH tunnel: `ssh -L 8080:10.100.0.3:8080 user@tiny1`

### Service Configuration

Both services run under the `mediacenter` group (GID 13000) for shared file access with other media services (Jellyfin, Sonarr, Radarr, etc.).

**Download paths** (requires `/data` mount):
- `/data/usenet/incomplete` - SABnzbd incomplete downloads
- `/data/usenet/complete` - SABnzbd completed downloads
- qBittorrent manages its own directories

**Backup window**: Both services pause 00:55-02:00 daily for backup operations.

---

## Troubleshooting

### Check VPN Connection Status

```bash
# Verify WireGuard tunnel is up
incus exec wireguard-gateway -- wg show

# Look for:
# - latest handshake: Recent timestamp (< 3 minutes ago)
# - transfer: Non-zero rx/tx bytes
# - peer: 8x7Y1OT1WRtShqk4lk3KbqpnPftTZLCpVu4VxRT/dzQ= (ProtonVPN NL#909)

# Check VPN DNS is reachable
incus exec wireguard-gateway -- ping -c 3 10.2.0.1

# Expected: 0% packet loss, ~140ms latency
```

### Verify Routing Configuration

```bash
# Check local traffic uses eth1 (NOT wg0)
incus exec wireguard-gateway -- ip route get 10.100.0.3

# Expected: "10.100.0.3 dev eth1 src 10.100.0.2"
# ❌ If shows "dev wg0", routing policy is broken

# Check internet traffic uses VPN
incus exec wireguard-gateway -- ip route get 8.8.8.8

# Expected: "8.8.8.8 dev wg0 table 1000 ..."

# View all routing policy rules
incus exec wireguard-gateway -- ip rule list

# Expected output:
# 0:    from all lookup local
# 5:    from all to 10.100.0.0/24 lookup main
# 6:    from all to 169.150.196.69 lookup main
# 10:   not from all fwmark 0x8888 lookup 1000
# 32766: from all lookup main
# 32767: from all lookup default
```

### Check DNS Configuration

```bash
# Test DNS resolution from media-download
incus exec media-download -- resolvectl query google.com

# Expected: Resolved successfully, "link: eth0"

# Verify no fallback DNS servers
incus exec media-download -- resolvectl status | grep -i fallback

# Expected: No fallback DNS servers listed (or empty)
# ❌ If shows 1.1.1.1, 8.8.8.8, etc., FallbackDNS not properly disabled

# Check systemd-resolved is using VPN DNS
incus exec wireguard-gateway -- resolvectl status | grep -A3 "Link.*wg0"

# Expected:
# Link X (wg0)
#     DNS Servers: 10.2.0.1
#     DNS Domain: ~.
#     Default Route: yes
```

### Test for DNS/IP Leaks

```bash
# Check external IP as seen by internet
incus exec media-download -- curl -s ifconfig.me

# Should return: ProtonVPN public IP
# ❌ If shows your home ISP IP, VPN is not working

# Compare with host's actual IP
curl -s ifconfig.me

# IPs should be DIFFERENT

# Test DNS leak
incus exec media-download -- dig +short whoami.akamai.net

# Should return: ProtonVPN IP (confirms DNS goes through VPN)
```

### Test VPN Kill Switch

```bash
# Stop VPN
incus exec wireguard-gateway -- systemctl stop systemd-networkd

# Wait for tunnel to go down
sleep 5

# Try to access internet - should FAIL completely
incus exec media-download -- timeout 10 curl ifconfig.me

# Expected: Timeout or "Could not resolve host"
# ❌ If succeeds, kill switch is not working (CRITICAL LEAK)

# Try DNS - should also FAIL
incus exec media-download -- timeout 10 resolvectl query google.com

# Expected: Timeout
# ❌ If succeeds, DNS is leaking to fallback servers

# Restart VPN
incus exec wireguard-gateway -- systemctl start systemd-networkd

# Wait for reconnection
sleep 15

# Internet should work again
incus exec media-download -- curl -s ifconfig.me

# Expected: ProtonVPN IP
```

---

## Architecture Decisions

### Why Policy-Based Routing?

Policy-based routing allows us to selectively route traffic based on destination:
- **Local subnet** (10.100.0.0/24): Use main routing table → eth1
- **Internet**: Use VPN routing table (table 1000) → wg0
- **VPN endpoint**: Use main routing table → prevent routing loop

This is more flexible than static routing and is the industry standard for VPN gateway scenarios.

### Why 10.100.0.0/24 Exception Rule?

Without the Priority 5 rule (`To: 10.100.0.0/24 → Table: main`), ALL traffic without the firewall mark gets sent to table 1000 (VPN routing table). This includes:
- Traffic destined for the gateway itself (10.100.0.2)
- Traffic between containers on vpnbr0

The result is a **routing black hole**: packets destined for local IPs get sent through the VPN tunnel, which doesn't know how to route them back to the local network.

The exception rule ensures local subnet traffic uses the main routing table, which has the correct eth1 route.

### Why FallbackDNS = null?

By default, systemd-resolved includes fallback DNS servers (Cloudflare 1.1.1.1, Google 8.8.8.8, etc.). When the primary DNS (10.2.0.1 - ProtonVPN) is slow or unavailable, systemd-resolved will use these fallback servers.

**Problem**: This creates a DNS leak - your DNS queries go to public DNS servers outside the VPN.

**Solution**: Set `FallbackDNS = null` to disable fallback. DNS will fail completely if VPN DNS is down, but this is intentional (kill switch behavior).

**Note**: This is a NixOS bug - setting `FallbackDNS = []` (empty list) doesn't work; must use `null`.

### Why Direct IP Access Instead of Port Forwarding?

We chose to access web UIs directly via `http://10.100.0.3:8080` instead of port forwarding through wireguard-gateway for these reasons:

1. **Simpler**: No complex iptables DNAT/FORWARD rules needed
2. **Easier to debug**: Direct connection path is straightforward
3. **Standard pattern**: Normal container-to-container communication
4. **Practical simplicity**: Aligns with design goal
5. **Still secure**: Network is already isolated to vpnbr0 (10.100.0.0/24)

Port forwarding through the gateway would add complexity without security benefit.

### Why systemd-networkd?

- Native WireGuard support (no external tools needed)
- Declarative configuration (fits NixOS philosophy)
- Powerful routing policy support
- Better suited for containers than NetworkManager

---

## Configuration Reference

### Routing Policy Rules (wireguard-gateway.nix)

```nix
routingPolicyRules = [
  # Priority 5: Keep local subnet traffic local
  {
    To = "10.100.0.0/24";
    Priority = 5;
    Table = "main";
  }
  # Priority 6: VPN endpoint bypass
  {
    To = "169.150.196.69/32";
    Priority = 6;
  }
  # Priority 10: Everything else to VPN
  {
    Family = "both";
    FirewallMark = 34952; # 0x8888
    InvertRule = true;
    Table = 1000;
    Priority = 10;
  }
];
```

### DNS Configuration

**wireguard-gateway** (systemd-resolved enabled):
- Listens on: 127.0.0.53 (local), 10.100.0.2 (eth1)
- Forwards to: 10.2.0.1 (ProtonVPN DNS)
- Fallback: None (FallbackDNS = null)

**media-download** (systemd-resolved enabled):
- Uses: 10.100.0.2 (wireguard-gateway)
- Fallback: None (FallbackDNS = null)

### Network Configuration

**vpnbr0 (Incus network)**:
```bash
incus network show vpnbr0
# ipv4.address: 10.100.0.1/24
# ipv4.nat: false (no NAT - gateway handles it)
# ipv6.address: none (IPv6 disabled)
```

**wireguard-gateway interfaces**:
- eth0: Management (incusbr0) - 10.223.27.196 (DHCP)
- eth1: VPN-routed network (vpnbr0) - 10.100.0.2/24 (static)
- wg0: WireGuard tunnel - 10.2.0.2/32 (static)

**media-download interfaces**:
- eth0: VPN-routed network (vpnbr0) - 10.100.0.3/24 (static)

---

## Testing Procedures

### Basic Functionality Test

```bash
# 1. Verify routing
incus exec wireguard-gateway -- ip route get 10.100.0.3
# Expected: dev eth1

# 2. Test connectivity
incus exec media-download -- ping -c 2 10.100.0.2
# Expected: 0% packet loss

# 3. Test DNS
incus exec media-download -- resolvectl query google.com
# Expected: Resolved successfully

# 4. Check external IP
incus exec media-download -- curl -s ifconfig.me
# Expected: ProtonVPN IP (NOT your home IP)

# 5. Test web UIs
curl -I http://10.100.0.3:8080  # qBittorrent
curl -I http://10.100.0.3:8085  # SABnzbd
# Expected: HTTP responses
```

### Security Validation Test

```bash
# 1. Verify no fallback DNS
incus exec media-download -- resolvectl status | grep -i fallback
# Expected: No fallback DNS or empty

# 2. Test kill switch (VPN failure)
incus exec wireguard-gateway -- systemctl stop systemd-networkd
sleep 5
incus exec media-download -- timeout 10 curl ifconfig.me
# Expected: Timeout (no internet without VPN)

# 3. Restart VPN
incus exec wireguard-gateway -- systemctl start systemd-networkd
sleep 15
incus exec media-download -- curl -s ifconfig.me
# Expected: ProtonVPN IP (VPN restored)

# 4. DNS leak test
incus exec media-download -- dig +short whoami.akamai.net
# Expected: ProtonVPN IP

# 5. IPv6 leak test
incus exec media-download -- curl -6 -s --max-time 5 ifconfig.me
# Expected: Timeout or error (IPv6 disabled)
```

---

## Network Setup Commands

These Incus network and device configurations were set up manually (not managed by Nix):

```bash
# Create vpnbr0 network (one-time setup)
incus network create vpnbr0 \
  ipv4.address=10.100.0.1/24 \
  ipv4.dhcp=false \
  ipv4.nat=false \
  ipv6.address=none

# Attach wireguard-gateway to vpnbr0
incus config device add wireguard-gateway eth1 nic parent=vpnbr0

# Attach media-download to vpnbr0
incus config device add media-download eth0 nic parent=vpnbr0
```

**Note**: These commands are documented here but don't need to be re-run unless recreating the containers from scratch.
