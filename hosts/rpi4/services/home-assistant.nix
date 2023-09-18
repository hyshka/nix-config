{ config, ... }:
{
  sops.secrets."home-assistant-secrets.yaml" = {
    owner = "hass";
    group = "hass";
    path = "/var/lib/hass/secrets.yaml";
    restartUnits = [ "home-assistant.service" ];
  };

  services.home-assistant = {
    enable = true;
    openfirewall = true;
    extracomponents = [
      # defaults
      "default_config"
      # components required to complete the onboarding
      "met"
      "esphome"
      "radio_browser"
      # extras
      "environment_canada"
    ];
    # todo writable until i know what to do
    configwritable = true;
    config = {
      homeassistant = {
      name = "home";
      latitude = "!secret latitude";
      longitude = "!secret longitude";
      elevation = "!secret elevation";
      unit_system = "metric";
      time_zone = "america/edmonton";
      currency = "cad";
      country = "ca";
      internal_url = "http://10.0.0.250:8123";
    };
    frontend = {
      themes = "!include_dir_merge_named themes";
    };
    http = {};
    feedreader.urls = [ "https://nixos.org/blogs.xml" ];
    };
  };
}
