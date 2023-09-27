{
  networking.firewall.allowedTCPPorts = [ 38000 ];

  services.openssh = {
      enable = true;
      ports = [ 38000 ];
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
  };
}
