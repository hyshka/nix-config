{
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      # defaults
      "default_config"
      # Components required to complete the onboarding
      "met"
      "esphome"
      "radio_browser"
      # extras
      "environment_canada"
    ];
  };
}
