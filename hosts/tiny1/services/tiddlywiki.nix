{
  # TODO
  # https://github.com/makefu/nixos-config/blob/d491179846b136bcc489c667b8637b6155392f52/2configs/deployment/wiki.euer.nix#L15
  #
  services.tiddlywiki.enable = true;
  listenOptions = {
    credentials = "../credentials.csv";
    port = 3456;
    readers = "(authenticated)";
  };
}
