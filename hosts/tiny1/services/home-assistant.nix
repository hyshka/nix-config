{pkgs, ...}: {
  sops.secrets."home-assistant-secrets.yaml" = {
    owner = "hass";
    group = "hass";
    path = "/var/lib/hass/secrets.yaml";
    restartUnits = ["home-assistant.service"];
  };

  services.home-assistant = {
    enable = true;
    package =
      pkgs.home-assistant.overrideAttrs
      (oldAttrs: {doInstallCheck = false;});
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
      "zha" # https://www.home-assistant.io/integrations/zha/
      "mqtt" # https://www.home-assistant.io/integrations/mqtt/
    ];
    customComponents = [
      pkgs.zha_toolkit
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
        external_url = "http://hass.home.hyshka.com/";
      };
      frontend = {
        themes = "!include_dir_merge_named themes";
      };
      http = {
        server_host = "127.0.0.1";
        use_x_forwarded_for = "true";
        trusted_proxies = "127.0.0.1";
      };
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
      # Enable zha_toolkit component
      zha_toolkit = {};

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
          json_attributes = ["joke" "id" "status"];
          value_template = "{{ value_json.joke }}";
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

      template = {
        sensor = [
          {
            name = "Feels like";
            device_class = "temperature";
            unit_of_measurement = "°C";
            state = ''
              {% if not is_state('sensor.Edmonton_humidex', 'unknown') %}
                {{ states('sensor.Edmonton_humidex') }}
              {% elif not is_state('sensor.Edmonton_wind_chill', 'unknown') %}
                {{ states('sensor.Edmonton_wind_chill') }}
              {% else %}
                {{ states('sensor.Edmonton_temperature') | round(0) }}
              {% endif %}
            '';
          }
          {
            name = "Vindstyrka TVOC Index";
            unique_id = "vindstyrka_tvoc_index";
            device_class = "aqi";
            unit_of_measurement = "";
            state = ''
              {{ None }}
            '';
          }
        ];
      };

      automation = [
        {
          alias = "Read vindstryrka tvoc";
          trigger = {
            platform = "time_pattern";
            seconds = "0";
            minutes = "/1";
          };
          action = [
            {
              service = "zha_toolkit.attr_read";
              data = {
                ieee = "5c:c7:c1:ff:fe:62:36:64";
                endpoint = 1;
                cluster = 64638;
                attribute = 0;
                manf = 4476;
                state_id = "sensor.vindstyrka_tvoc_index";
              };
            }
          ];
        }
      ];
    };
  };
}
