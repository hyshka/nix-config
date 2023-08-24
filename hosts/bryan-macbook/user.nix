{ inputs, pkgs, ... }:
let
  username = "hyshka";
in
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCTi8LybJv9rM1PY+89RizysnNS0qe17peP1lsribcY+VuEW1aZrjYePJKVyFlIUqQnPGr9zK2FsLqU+Y40hfNQMITlHQMCbrWLvGdPvR2uP17+DFvZSp+ox0KVIjqOgxpLIWbszHKzfA1g8FJfzpH7j1kzP7bEonUXAGd3eVtf2kuzELKl7pI4uQyuoKF6ti1EMKQEOivLJm9aphz8/Bk+aZVgFy2srCxhqpWM5v967iNOK+UtPAqStrkJTvc1NtmMe6YQ099lRltq5dLerBfb0r5BdTKa+oTrgMELzV1YOv1i5Nj21RUz0kDT1eiVoqmyYAIlB8Rn01qByCU+2FH1 bryan@hyshka.com"
    ];
  };

  nix.settings.trusted-users = [ username ];
}
