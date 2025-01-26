{
  # TODO: add tailnet
  networking.nameservers = [
    # tiny1 adguardhome, prefer tailnet
    "100.116.243.20"
    "10.0.0.240"
    # Fallback to Cloudflare DNS
    "1.1.1.1"
    "1.0.0.1"
  ];
}
