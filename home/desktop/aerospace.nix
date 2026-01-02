{
  xdg.configFile = {
    "aerospace" = {
      text = ''
        # Enhanced Aerospace configuration with automatic app placement,
        # workspace naming, summon mode, and improved keybindings

        # Start AeroSpace at login
        start-at-login = true

        # You can use it to add commands that run after login to macOS user session.
        after-login-command = []

        # You can use it to add commands that run after AeroSpace startup.
        after-startup-command = []

        # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
        enable-normalization-flatten-containers = true
        enable-normalization-opposite-orientation-for-nested-containers = true

        # Accordion padding
        accordion-padding = 30

        # Default layout
        default-root-container-layout = 'tiles'

        # Default orientation
        default-root-container-orientation = 'auto'

        # Mouse follows focus when focused monitor changes
        on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

        # Disable macOS "Hide application" (cmd-h) feature
        automatically-unhide-macos-hidden-apps = false

        # Workspace naming
        [workspace.1]
        name = "comm"  # Slack, Spotify, communication

        [workspace.2]
        name = "term"  # Alacritty, terminals

        [workspace.3]
        name = "notes"   # Brave browser (secondary)

        [workspace.4]
        name = "web"  # Brave browser (primary)

        [workspace.5]
        name = "media" # Zoom

        # Window rules - automatic app placement
        [[on-window-detected]]
        if.app-id = "com.tinyspeck.slackmacgap"
        run = "move-node-to-workspace 1"

        [[on-window-detected]]
        if.app-id = "org.alacritty"
        run = "move-node-to-workspace 2"

        [[on-window-detected]]
        if.app-id = "com.spotify.client"
        run = "move-node-to-workspace 1"

        [[on-window-detected]]
        if.app-id = "us.zoom.xos"
        run = "move-node-to-workspace 5"

        # Brave goes to workspace 4 by default (you can move to 3 manually)
        [[on-window-detected]]
        if.app-id = "com.brave.Browser"
        run = "move-node-to-workspace 4"

        # Floating windows (don't tile these)
        [[on-window-detected]]
        if.app-id = "com.apple.systempreferences"
        run = "layout floating"

        [[on-window-detected]]
        if.app-id = "com.1password.1password"
        run = "layout floating"

        # Key mapping
        [key-mapping]
        preset = 'qwerty'

        # Gaps between windows
        [gaps]
        inner.horizontal = 0
        inner.vertical =   0
        outer.left =       0
        outer.bottom =     0
        outer.top =        0
        outer.right =      0

        # Main mode keybindings
        [mode.main.binding]

        # Navigation (Vi-style, with wrap-around)
        alt-h = 'focus --boundaries-action wrap-around-the-workspace left'
        alt-j = 'focus --boundaries-action wrap-around-the-workspace down'
        alt-k = 'focus --boundaries-action wrap-around-the-workspace up'
        alt-l = 'focus --boundaries-action wrap-around-the-workspace right'

        # Moving windows
        alt-shift-h = 'move left'
        alt-shift-j = 'move down'
        alt-shift-k = 'move up'
        alt-shift-l = 'move right'

        # Workspace switching
        alt-1 = 'workspace 1'
        alt-2 = 'workspace 2'
        alt-3 = 'workspace 3'
        alt-4 = 'workspace 4'
        alt-5 = 'workspace 5'
        alt-6 = 'workspace 6'
        alt-7 = 'workspace 7'
        alt-8 = 'workspace 8'
        alt-9 = 'workspace 9'

        # Move window to workspace
        alt-shift-1 = 'move-node-to-workspace 1'
        alt-shift-2 = 'move-node-to-workspace 2'
        alt-shift-3 = 'move-node-to-workspace 3'
        alt-shift-4 = 'move-node-to-workspace 4'
        alt-shift-5 = 'move-node-to-workspace 5'
        alt-shift-6 = 'move-node-to-workspace 6'
        alt-shift-7 = 'move-node-to-workspace 7'
        alt-shift-8 = 'move-node-to-workspace 8'
        alt-shift-9 = 'move-node-to-workspace 9'

        # Layouts
        alt-s = 'layout v_accordion'  # Vertical accordion
        alt-w = 'layout h_accordion'  # Horizontal accordion
        alt-e = 'layout tiles horizontal vertical'  # Toggle tiles layout
        alt-shift-space = 'layout floating tiling'  # Toggle floating/tiling

        # Additional useful keybindings
        alt-tab = 'workspace-back-and-forth'  # Toggle between current and previous workspace
        alt-shift-n = 'move-node-to-monitor --wrap-around next'  # Move to next monitor
        alt-shift-p = 'move-node-to-monitor --wrap-around prev'  # Move to previous monitor
        alt-shift-equal = 'balance-sizes'  # Balance window sizes
        alt-shift-q = 'close'  # Close window
        alt-shift-f = 'flatten-workspace-tree'  # Remove nested containers

        # Summon mode - quickly open apps (Alt+T then letter)
        alt-t = 'mode summon'

        # Fullscreen
        alt-f = 'fullscreen'

        # Join/split
        alt-g = 'join-with left'
        alt-v = 'join-with up'

        # Resize mode
        alt-r = 'mode resize'

        # Reload config
        alt-shift-c = 'reload-config'

        # Summon mode - press alt-t then a letter to open apps
        [mode.summon.binding]
        b = ['exec-and-forget open -a "Brave Browser"', 'mode main']
        s = ['exec-and-forget open -a "Slack"', 'mode main']
        a = ['exec-and-forget open -a "Alacritty"', 'mode main']
        m = ['exec-and-forget open -a "Spotify"', 'mode main']
        z = ['exec-and-forget open -a "zoom.us"', 'mode main']
        esc = 'mode main'
        enter = 'mode main'

        # Enhanced resize mode with larger increments
        [mode.resize.binding]
        h = 'resize width -100'  # Larger steps for faster resizing
        j = 'resize height +100'
        k = 'resize height -100'
        l = 'resize width +100'
        shift-h = 'resize width -50'  # Fine-grained with shift
        shift-j = 'resize height +50'
        shift-k = 'resize height -50'
        shift-l = 'resize width +50'
        enter = 'mode main'
        esc = 'mode main'
      '';
      target = "aerospace/aerospace.toml";
    };
  };
}
