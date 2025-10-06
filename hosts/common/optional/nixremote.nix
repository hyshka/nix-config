{
  users.groups.nixremote = {};
  users.users.nixremote = {
    description = "Nix Remote Builder User";
    isNormalUser = true;
    group = "nixremote";
    # Don't allow shell access
    useDefaultShell = false;
    # Disable su and password login
    hashedPasswordFile = null;
    hashedPassword = "!";
    homeMode = "555";
    # add root key for each client
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIED7CbbCMdI59FzAowgxS9xHUEd9iF2qt3iA5McxCtqF root@ashyn"
    ];
  };
  nix.settings.trusted-users = ["nixremote"];
}
