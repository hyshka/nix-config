{
  security.acme = {
    acceptTerms = true;
    defaults.email = "bryan@hyshka.com";
    #certs = {
    #  "*.home.hyshka.com" = {
    #    #extraDomainNames = ["hass.home.hyshka.com" "glances.home.hyshka.com" "dashboard.home.hyshka.com"];
    #    # TODO
    #    webroot = "/var/lib/acme/acme-challenge";
    #    #group = "nginx";
    #    #extraDomainNames = ["*.home.hyshka.com"];
    #  };
    #};
  };
}
