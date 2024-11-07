{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModule
  ];
  sops = {
    #age.keyFile = "/home/hyshka/.age-key.txt"; # must have no password!
    # It's also possible to use a ssh key, but only when it has no password:
    #age.sshKeyPaths = [ "/home/user/path-to-ssh-key" ];
    gnupg = with config.home; {
      home = "${homeDirectory}/.gnupg";
    };
  };
}
