{
  # Espanso is installed via Homebrew (see hosts/darwin/bryan-macbook/homebrew.nix)
  # The home-manager service module doesn't work properly on macOS, so we manage
  # configuration files declaratively using home.file instead.

  # TODO: handle linux file paths as well as macos
  # NOTE: Add private matchers to ~/Library/Application Support/espanso/match/private.yml
  home.file = {
    # Main configuration file
    "Library/Application Support/espanso/config/default.yml".text = ''
      # Toggle key: double-tap Alt to disable/enable
      toggle_key: ALT

      # Use clipboard for long texts (faster)
      backend: Clipboard
      clipboard_threshold: 100

      # Auto-restart on config changes
      auto_restart: true

      # Preserve clipboard after paste
      preserve_clipboard: true

      # Show notifications for errors
      show_notifications: true
    '';

    # Base snippets
    "Library/Application Support/espanso/match/base.yml".text = ''
      matches:
        # Django commands
        - trigger: ":dr"
          replace: "python manage.py runserver --skip-checks 0.0.0.0:8000"
        - trigger: ":dR"
          replace: "WEBPACK_LOADER_USE_PROD=1 python manage.py runserver 0.0.0.0:8000"
        - trigger: ":dt"
          replace: "python manage.py test --keepdb"
        - trigger: ":dm"
          replace: "python manage.py migrate"

        # Python debugging
        - trigger: ":pdb"
          replace: "__import__('pdb').set_trace()  # fmt: skip"
        - trigger: ":pudb"
          replace: "from pudb import set_trace; set_trace() # fmt: skip"
        - trigger: ":Pudb"
          replace: "from pudb.remote import set_trace; set_trace(term_size=(200, 60), host='0.0.0.0', port=6900) # fmt: skip"

        # Dynamic date/time
        - trigger: ":date"
          replace: "{{mydate}}"
          vars:
            - name: mydate
              type: date
              params:
                format: "%Y-%m-%d"

        - trigger: ":time"
          replace: "{{mytime}}"
          vars:
            - name: mytime
              type: date
              params:
                format: "%H:%M"

        # Common phrases
        - trigger: ":lgtm"
          replace: "Looks good to me!"
        - trigger: ":ty"
          replace: "Thank you!"
        - trigger: ":wfh"
          replace: "Working from home"
    '';

    # Terminal-specific snippets (only active in terminal apps)
    "Library/Application Support/espanso/match/terminal.yml".text = ''
      filter_app_ids:
        - "io.alacritty"
        - "com.apple.Terminal"
        - "com.googlecode.iterm2"

      matches:
        # Git shortcuts
        - trigger: ":gc"
          replace: "git commit -m '$|$'"
        - trigger: ":gp"
          replace: "git push"
        - trigger: ":gl"
          replace: "git log --oneline --graph --all"
        - trigger: ":gco"
          replace: "git checkout"

        # Nix shortcuts
        - trigger: ":nhs"
          replace: "nh home switch"
        - trigger: ":nds"
          replace: "nh darwin switch"
        - trigger: ":nfu"
          replace: "nix flake update"

        # Tmux shortcuts
        - trigger: ":tpd"
          replace: "tmuxp load dashboard"
        - trigger: ":tpm"
          replace: "tmuxp load muckrack"
    '';
  };
}
