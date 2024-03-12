{
  services.openssh = {
    enable = true;
    ports = [38002];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
