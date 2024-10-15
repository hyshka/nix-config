{
  xdg.configFile = {
    "aerospace" = {
      text = ''
        # You can use it to add commands that run after login to macOS user session.
        # 'start-at-login' needs to be 'true' for 'after-login-command' to work
        # Available commands: https://nikitabobko.github.io/AeroSpace/commands
        after-login-command = []

        # You can use it to add commands that run after AeroSpace startup.
        # 'after-startup-command' is run after 'after-login-command'
        # Available commands : https://nikitabobko.github.io/AeroSpace/commands
        after-startup-command = []

        # Start AeroSpace at login
        start-at-login = true

        # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
        enable-normalization-flatten-containers = true
        enable-normalization-opposite-orientation-for-nested-containers = true

        # See: https://nikitabobko.github.io/AeroSpace/guide#layouts
        # The 'accordion-padding' specifies the size of accordion padding
        # You can set 0 to disable the padding feature
        accordion-padding = 30

        # Possible values: tiles|accordion
        default-root-container-layout = 'tiles'

        # Possible values: horizontal|vertical|auto
        # 'auto' means: wide monitor (anything wider than high) gets horizontal orientation,
        #               tall monitor (anything higher than wide) gets vertical orientation
        default-root-container-orientation = 'auto'

        # Mouse follows focus when focused monitor changes
        # Drop it from your config, if you don't like this behavior
        # See https://nikitabobko.github.io/AeroSpace/guide#on-focus-changed-callbacks
        # See https://nikitabobko.github.io/AeroSpace/commands#move-mouse
        # Fallback value (if you omit the key): on-focused-monitor-changed = []
        on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

        # You can effectively turn off macOS "Hide application" (cmd-h) feature by toggling this flag
        # Useful if you don't use this macOS feature, but accidentally hit cmd-h or cmd-alt-h key
        # Also see: https://nikitabobko.github.io/AeroSpace/goodness#disable-hide-app
        automatically-unhide-macos-hidden-apps = false

        # Possible values: (qwerty|dvorak)
        # See https://nikitabobko.github.io/AeroSpace/guide#key-mapping
        [key-mapping]
        preset = 'qwerty'

        # Gaps between windows (inner-*) and between monitor edges (outer-*).
        # Possible values:
        # - Constant:     gaps.outer.top = 8
        # - Per monitor:  gaps.outer.top = [{ monitor.main = 16 }, { monitor."some-pattern" = 32 }, 24]
        #                 In this example, 24 is a default value when there is no match.
        #                 Monitor pattern is the same as for 'workspace-to-monitor-force-assignment'.
        #                 See: https://nikitabobko.github.io/AeroSpace/guide#assign-workspaces-to-monitors
        [gaps]
        inner.horizontal = 0
        inner.vertical =   0
        outer.left =       0
        outer.bottom =     0
        outer.top =        0
        outer.right =      0

        # 'main' binding mode declaration
        # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
        # 'main' binding mode must be always presented
        # Fallback value (if you omit the key): mode.main.binding = {}
        [mode.main.binding]

        # All possible keys:
        # - Letters.        a, b, c, ..., z
        # - Numbers.        0, 1, 2, ..., 9
        # - Keypad numbers. keypad0, keypad1, keypad2, ..., keypad9
        # - F-keys.         f1, f2, ..., f20
        # - Special keys.   minus, equal, period, comma, slash, backslash, quote, semicolon, backtick,
        #                   leftSquareBracket, rightSquareBracket, space, enter, esc, backspace, tab
        # - Keypad special. keypadClear, keypadDecimalMark, keypadDivide, keypadEnter, keypadEqual,
        #                   keypadMinus, keypadMultiply, keypadPlus
        # - Arrows.         left, down, up, right

        # All possible modifiers: cmd, alt, ctrl, shift

        # All possible commands: https://nikitabobko.github.io/AeroSpace/commands

        # See: https://nikitabobko.github.io/AeroSpace/commands#exec-and-forget
        # You can uncomment the following lines to open up terminal with alt + enter shortcut (like in i3)
        alt-enter = ''''exec-and-forget osascript -e '
        tell application "Terminal"
            do script
            activate
        end tell'
        ''''

        # See: https://nikitabobko.github.io/AeroSpace/commands#focus
        alt-h = 'focus --boundaries-action wrap-around-the-workspace left'
        alt-j = 'focus --boundaries-action wrap-around-the-workspace down'
        alt-k = 'focus --boundaries-action wrap-around-the-workspace up'
        alt-l = 'focus --boundaries-action wrap-around-the-workspace right'

        # See: https://nikitabobko.github.io/AeroSpace/commands#move
        alt-shift-h = 'move left'
        alt-shift-j = 'move down'
        alt-shift-k = 'move up'
        alt-shift-l = 'move right'

        # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
        alt-1 = 'workspace 1'
        alt-2 = 'workspace 2'
        alt-3 = 'workspace 3'
        alt-4 = 'workspace 4'
        alt-5 = 'workspace 5'
        alt-6 = 'workspace 6'
        alt-7 = 'workspace 7'
        alt-8 = 'workspace 8'
        alt-9 = 'workspace 9'

        # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
        alt-shift-1 = 'move-node-to-workspace 1'
        alt-shift-2 = 'move-node-to-workspace 2'
        alt-shift-3 = 'move-node-to-workspace 3'
        alt-shift-4 = 'move-node-to-workspace 4'
        alt-shift-5 = 'move-node-to-workspace 5'
        alt-shift-6 = 'move-node-to-workspace 6'
        alt-shift-7 = 'move-node-to-workspace 7'
        alt-shift-8 = 'move-node-to-workspace 8'
        alt-shift-9 = 'move-node-to-workspace 9'

        alt-g = 'join-with left'
        alt-v = 'join-with up'

        alt-f = 'fullscreen'

        alt-s = 'layout v_accordion' # 'layout stacking' in i3
        alt-w = 'layout h_accordion' # 'layout tabbed' in i3
        alt-e = 'layout tiles horizontal vertical' # 'layout toggle split' in i3

        alt-shift-space = 'layout floating tiling' # 'floating toggle' in i3

        # Not supported, because this command is redundant in AeroSpace mental model.
        # See: https://nikitabobko.github.io/AeroSpace/guide#floating-windows
        #alt-space = 'focus toggle_tiling_floating'

        # `focus parent`/`focus child` are not yet supported, and it's not clear whether they
        # should be supported at all https://github.com/nikitabobko/AeroSpace/issues/5
        # alt-a = 'focus parent'

        alt-shift-c = 'reload-config'

        alt-r = 'mode resize'

        [mode.resize.binding]
        # See: https://nikitabobko.github.io/AeroSpace/commands#resize
        h = 'resize width -50'
        j = 'resize height +50'
        k = 'resize height -50'
        l = 'resize width +50'
        enter = 'mode main'
        esc = 'mode main'
      '';
      target = "aerospace/aerospace.toml";
    };
  };
}
