{pkgs, ...}: {
  services.espanso = {
    enable = false;
    package = pkgs.espanso-wayland;
    settings = {
      matches = [
        {
          trigger = ":e1";
          replace = "bryan@hyshka.com";
        }
        {
          trigger = ":e2";
          replace = "bryan@muckrack.com";
        }
        {
          trigger = ":dr";
          replace = "python manage.py runserver 0.0.0.0:8000";
        }
        {
          trigger = ":dR";
          replace = "WEBPACK_LOADER_USE_PROD=1 python manage.py runserver 0.0.0.0:8000";
        }
        {
          trigger = ":dt";
          replace = "python manage.py test --keepdb --nomigrations";
        }
        {
          trigger = ":pdb";
          replace = "__import__('pdb').set_trace()  # FIXME";
        }
        {
          trigger = ":pudb";
          replace = "import pudb; pu.db  # FIXME";
        }
        {
          # Dates
          trigger = ":date";
          replace = "{{mydate}}";
          vars = [
            {
              name = "mydate";
              type = "date";
              params = {format = "%Y-%m-%d";};
            }
          ];
        }
        {
          # Shell commands
          trigger = ":shell";
          replace = "{{output}}";
          vars = [
            {
              name = "output";
              type = "shell";
              params = {cmd = "echo Hello from your shell";};
            }
          ];
        }
        {
          trigger = ":vim";
          replace = "{{output}}";
          vars = [
            {
              name = "output";
              type = "shell";
              params = {cmd = "kitty nvim";};
            }
          ];
        }
      ];
    };
  };
}
