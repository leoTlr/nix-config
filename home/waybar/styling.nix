{ config }:
let
    color = config.colorScheme.palette;

    mkColor = base: "#${color."base0${toString base}"}";
in
# https://github.com/manjaro-sway/desktop-settings/tree/sway/community/sway/usr/share/sway/templates
''

@define-color background_color          ${mkColor "1"};
@define-color error_color               ${mkColor "8"};
@define-color theme_bg_color            ${mkColor "0"};
@define-color theme_selected_bg_color   ${mkColor "4"};
@define-color warning_color             ${mkColor "A"};


/* -----------------------------------------------------------------------------
 * Keyframes
 * -------------------------------------------------------------------------- */

@keyframes blink-warning {
    70% {
        color: @wm_icon_bg;
    }

    to {
        color: @wm_icon_bg;
        background-color: @warning_color;
    }
}

@keyframes blink-critical {
    70% {
        color: @wm_icon_bg;
    }

    to {
        color: @wm_icon_bg;
        background-color: @error_color;
    }
}

/* -----------------------------------------------------------------------------
 * Base styles
 * -------------------------------------------------------------------------- */

/* Reset all styles */
* {
    border: none;
    border-radius: 0;
    min-height: 0;
    margin: 0;
    padding: 0;
    font-family: "JetBrainsMono NF", "Roboto Mono", sans-serif;
}

/* The whole bar */
window#waybar {
    background: @theme_bg_color;
    color: @wm_icon_bg;
    font-size: 14px;
}

/* Each module */
#custom-pacman,
#custom-menu,
#custom-help,
#custom-scratchpad,
#custom-github,
#custom-clipboard,
#custom-zeit,
#custom-dnd,
#custom-valent,
#custom-idle_inhibitor,
#bluetooth,
#battery,
#clock,
#cpu,
#memory,
#mode,
#network,
#pulseaudio,
#temperature,
#backlight,
#language,
#custom-adaptive-light,
#custom-sunset,
#custom-playerctl,
#custom-weather,
#tray {
    padding-left: 10px;
    padding-right: 10px;
}

/* -----------------------------------------------------------------------------
 * Module styles
 * -------------------------------------------------------------------------- */

#custom-scratchpad,
#custom-menu,
#workspaces button.focused,
#clock {
    color: @theme_bg_color;
    background-color: @theme_selected_bg_color;
}

#custom-zeit.tracking {
    background-color: @warning_color;
}

#battery {
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#battery.warning {
    color: @warning_color;
}

#battery.critical {
    color: @error_color;
}

#battery.warning.discharging {
    animation-name: blink-warning;
    animation-duration: 3s;
}

#battery.critical.discharging {
    animation-name: blink-critical;
    animation-duration: 2s;
}

#clock {
    font-weight: bold;
}

#cpu.warning {
    color: @warning_color;
}

#cpu.critical {
    color: @error_color;
}

#custom-menu {
    padding-left: 8px;
    padding-right: 13px;
}

#memory {
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#memory.warning {
    color: @warning_color;
}

#memory.critical {
    color: @error_color;
    animation-name: blink-critical;
    animation-duration: 2s;
}

#mode {
    background: @background_color;
}

#network.disconnected {
    color: @warning_color;
}

#pulseaudio.muted {
    color: @warning_color;
}

#temperature.critical {
    color: @error_color;
}

#workspaces button {
    border-top: 2px solid transparent;
    /* To compensate for the top border and still have vertical centering */
    padding-bottom: 2px;
    padding-left: 10px;
    padding-right: 10px;
    color: @theme_selected_bg_color;
}

#workspaces button.focused {
    border-color: @theme_selected_bg_color;
}

#workspaces button.urgent {
    border-color: @error_color;
    color: @error_color;
}

#custom-pacman {
    color: @warning_color;
}

#bluetooth.disabled {
    color: @warning_color;
}

#custom-wf-recorder {
    color: @error_color;
    padding-right: 10px;
}

#custom-valent.dangerously-empty {
    color: @warning_color;
}

#custom-waybar-systemd-indicator.degraded {
    color: @error_color;
    animation-name: blink-error;
    animation-duration: 2s;
}
''