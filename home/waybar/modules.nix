{ pkgs }:
let
  workspaces = {
    format = "{icon}";
    format-icons = {
      "1" = "";
      "2" = "";
      "3" = "";
      active = "";
      default = "";
      urgent = "";
    };
    on-click = "activate";
    # persistent_workspaces = { "*" = 10; };
  };
in
{

  "wlr/workspaces" = workspaces;
  "hyprland/workspaces" = workspaces;

  "systemd-failed-units" = {
    interval = 10;
    hide-on-ok = false;
	  format= "{nr_failed} ✗";
	  format-ok = "{nr_failed} ✓";
	  system= true;
	  user = true;
  };

  bluetooth = {
    format = "";
    format-connected = " {num_connections}";
    format-disabled = "";
    tooltip-format = " {device_alias}";
    tooltip-format-connected = "{device_enumerate}";
    tooltip-format-enumerate-connected = " {device_alias}";
  };

  clock = {
    interval = 60;
    format = "{:%e %b %Y %H:%M}";
    tooltip = true;
    tooltip-format = "<big>{:%B %Y}</big>\n<tt>{calendar}</tt>";
    #on-click = "swaymsg exec \\$calendar";
  };

  cpu = {
    format = "󰘚 {usage}%";
    format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
    interval = 5;
    states = {
      warning = 70;
      critical = 90;
    };
  };

  battery = {
    interval = 1;
    states = {
      warning = 30;
      critical = 15;
    };
    format-charging = "󰂄 {capacity}%";
    format = "{icon} {capacity}%";
    format-icons = ["󱃍" "󰁺" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
    tooltip = true;
  };

  backlight = {
    format = "{icon} {percent}%";
    format-icons = ["󰃞" "󰃟" "󰃠"];
    #on-scroll-up = "swaymsg exec \\$brightness_up";
    #on-scroll-down = "swaymsg exec \\$brightness_down;
  };

  "custom/menu" = {
    format = "";
    tooltip = false;
    on-click = "${pkgs.wofi}/bin/wofi --show drun";
  };

  memory = {
    format = "󰾆 {percentage}%";
    interval = 5;
    tooltip = true;
    tooltip-format = " {used:0.1f}GB/{total:0.1f}GB";
    states = {
      warning = 70;
      critical = 90;
    };
  };

  network = {
    format-wifi = " ";
    format-ethernet = "󰈀";
    format-disconnected = "󰖪";
    tooltip-format = "{icon} {ifname}: {ipaddr}";
    tooltip-format-ethernet = "{icon} {ifname}: {ipaddr}";
    tooltip-format-wifi = "{icon} {ifname} ({essid}): {ipaddr}";
    tooltip-format-disconnected = "{icon} disconnected";
    tooltip-format-disabled = "{icon} disabled";
    interval = 5;
  };

  pulseaudio = {
    format = "{icon} {volume}%{format_source}";
    format-icons = {
      headphone = "󰋋";
      headset = "󰋎";
      default = ["󰕿" "󰖀" "󰕾"];
    };
    format-muted = "婢 {volume}%";
    format-source = "";
    on-click = "pavucontrol -t 3";
    on-click-middle = "pamixer -t";
    on-scroll-down = "pamixer -d 5";
    on-scroll-up = "pamixer -i 5";
    scroll-step = 5;
    tooltip-format = "{icon} {desc} {volume}%";
  };

  "pulseaudio#microphone" = {
    format = "{format_source}";
    format-source = "  {volume}%";
    format-source-muted = "  {volume}%";
    on-click = "pavucontrol -t 4";
    on-click-middle = "pamixer --default-source -t";
    on-scroll-down = "pamixer --default-source -d 5";
    on-scroll-up = "pamixer --default-source -i 5";
    scroll-step = 5;
  };

  tray = {
    icon-size = 15;
    spacing = 5;
  };

}