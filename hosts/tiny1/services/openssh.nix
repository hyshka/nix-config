{
  networking.firewall.allowedTCPPorts = [38000];

  services.openssh = {
    enable = true;
    ports = [38000];
    settings = {
      PasswordAuthentication = false;
      # permit root to enable remote deployment
      # TODO find a way to deny root
      #PermitRootLogin = "no";
      # TODO force publickey auth
      # https://wiki.archlinux.org/title/OpenSSH#Force_public_key_authentication
    };
  };
}
