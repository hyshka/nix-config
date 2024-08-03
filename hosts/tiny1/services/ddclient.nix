{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [ddclient];

  sops.secrets = {
    ddclient_cloudFlareApiKey = {};
  };

  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    zone = "hyshka.com";
    username = "bryan@hyshka.com";
    use = "web";
    passwordFile = config.sops.secrets.ddclient_cloudFlareApiKey.path;
  };
}
