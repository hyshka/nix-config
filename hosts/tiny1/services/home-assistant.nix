{config, ...}: {
  sops.secrets."home-assistant-secrets.yaml" = {
    owner = "hass";
    group = "hass";
    path = "/var/lib/hass/secrets.yaml";
    restartUnits = ["home-assistant.service"];
  };

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      # defaults
      "default_config"
      # components required to complete the onboarding
      "met"
      "esphome"
      "radio_browser"
      # extras
      "environment_canada" # https://www.home-assistant.io/integrations/environment_canada/
      # station id: AB/s0000045
      "qbittorrent" # https://www.home-assistant.io/integrations/qbittorrent/
      "radarr" # https://www.home-assistant.io/integrations/radarr/
      "sonarr" # https://www.home-assistant.io/integrations/sonarr/
      "syncthing" # https://www.home-assistant.io/integrations/syncthing/
      "glances" # https://www.home-assistant.io/integrations/glances/
      "feedreader" # https://www.home-assistant.io/integrations/feedreader/
    ];
    # todo writable until i know what to do
    configWritable = true;
    config = {
      homeassistant = {
        name = "home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = "!secret elevation";
        unit_system = "metric";
        time_zone = "America/Edmonton";
        currency = "CAD";
        country = "CA";
        temperature_unit = "C";
        internal_url = "http://10.0.0.240:8123";
      };
      frontend = {
        themes = "!include_dir_merge_named themes";
      };
      feedreader.urls = ["https://nixos.org/blogs.xml"];
      http = {};
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};

      # weather
      weather = [
        { platform = "environment_canada"; }
      ];
      camera = [
        { platform = "environment_canada"; }
      ];

      # dad jokes
      conversation.intents = {
        TellJoke = [
          "Tell [me] (a joke|something funny|a dad joke)"
        ];
      };
      sensor = [
        {
          name = "random_joke";
          platform = "rest";
          json_attributes = "joke";
          resource = "https://icanhazdadjoke.com/";
          scan_interval = "3600";
          headers.Accept = "application/json";
        }
      ];
      intent_script.TellJoke = {
        speech.text = ''{{ state_attr("sensor.random_joke", "joke") }}'';
        action = {
          service = "homeassistant.update_entity";
          entity_id = "sensor.random_joke";
        };
      };
    };
  };
}
