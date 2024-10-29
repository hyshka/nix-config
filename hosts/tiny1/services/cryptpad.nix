{...}: {
  services.cryptpad = {
    enable = true;
    settings = {
      httpPort = 3006;
      httpUnsafeOrigin = "https://cryptpad.home.hyshka.com";
      httpSafeOrigin = "https://cryptpad-ui.home.hyshka.com";
      websocketPort = 3003; # default
      adminKeys = []; # TODO
    };
  };
}
