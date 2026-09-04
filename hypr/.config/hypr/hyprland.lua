hl.monitor({ mode = "preferred", position = "auto", scale = 1 })

-- Set programs that you use
terminal = "kitty"
fileManager = "nautilus"
browser = "chromium"
menu = "wofi -iIa --show drun --style ~/.config/wofi/style.css -W 800"

cursorTheme = "BreezeX-Black"
cursorSize = "32"

-- Execute your favorite apps at launch
hl.on("hyprland.start", function ()
  hl.exec_cmd("uwsm app -- waybar")
  hl.exec_cmd("uwsm app -- hypridle")
  hl.exec_cmd("uwsm app -- swaybg -i ~/.dotfiles/nix/city.jpg -m fill")
  hl.exec_cmd("uwsm app -- hyprctl setcursor " .. cursorTheme .. " " .. cursorSize)
  hl.exec_cmd("uwsm app -- yin_yang --minimized")
end)

hl.env("XCURSOR_THEME", cursorTheme)
hl.env("XCURSOR_SIZE", cursorSize)
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("TERMINAL", terminal)

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true
        },
        natural_scroll = true,
        sensitivity = 0,
        repeat_delay = 200,
        repeat_rate = 30
    },
    cursor = {
        hide_on_key_press = true
    },
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 2,
        col = {
            active_border = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)"
        },
        snap = {
            border_overlap = true
        },
        layout = "dwindle",
        allow_tearing = false
    },
    decoration = {
        rounding = 0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)"
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696
        }
    },
    group = {
        col = {
            border_active = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
            border_inactive = "rgba(595959aa)"
        },
        groupbar = {
            font_family = "JetBrainsMono Nerd Font",
            gradients = true,
            col = {
                active = "rgba(24242499)",
                inactive = "rgba(00000099)"
            },
            gaps_in = 0,
            gaps_out = 0
        }
    },
    animations = {
        enabled = true
    },
    dwindle = {
        pseudotile = true,
        preserve_split = true
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true
    }
})

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

-- Source omarchy bindings
-- source = ~/.local/share/omarchy/default/hypr/bindings/utilities.conf

hl.window_rule({ match = { tag = "floating-window" }, float = true, center = true, size = "800 600" })
hl.window_rule({ match = { class = "blueberry.py|Impala|Wiremix|org.gnome.NautilusPreviewer|com.gabm.satty|Omarchy|About|TUI.float|Netsoft-com.netsoft.hubstaff|localsend" }, tag = "floating-window" })
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk|DesktopEditors|org.gnome.Nautilus", title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files)" }, tag = "floating-window" })
hl.window_rule({ match = { class = "Slack|sublime_merge" }, float = true, size = "995 800" })
hl.window_rule({ match = { title = "Picture in picture" }, border_size = 0, rounding = 15 })
hl.window_rule({ match = { class = "^Godot$", title = "^Godot$" }, tile = true })
hl.window_rule({ match = { class = "^blender$", title = "^Blender$" }, size = "900 600", center = true })
hl.window_rule({ match = { class = "better_control.py" }, float = true, border_size = 0, animation = "slide top", move = "(monitor_w-810) (52)", size = "800 550", rounding = 10, opacity = "0.95" })
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

hl.layer_rule({ match = { namespace = "wofi" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "wofi" }, blur = true })

hl.bind("SUPER + X", hl.dsp.window.kill())
hl.bind("SUPER + C", hl.dsp.window.kill())
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + SHIFT + G", hl.dsp.group.toggle())
hl.bind("SUPER + G", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + ALT + G", hl.dsp.group.active({ index = "f" }))

hl.bind("SUPER + W", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + R", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + B", hl.dsp.exec_cmd(browser), { description = "Browser" })
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd(browser .. " --private"), { description = "Browser (private)" })
hl.bind("SUPER + ALT + SPACE", hl.dsp.exec_cmd("omarchy-menu"), { description = "Omarchy menu" })
hl.bind("SUPER + CTRL + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"), { description = "Lock screen" })
hl.bind("SUPER + M", hl.dsp.exec_cmd("omarchy-launch-or-focus lollypop"), { description = "Music" })
hl.bind("SUPER + A", hl.dsp.exec_cmd('omarchy-launch-webapp "https://gemini.google.com"'), { description = "Grok" })
hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal .. " -e btop"), { description = "Top" })

hl.bind("ALT + SHIFT + 3", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("ALT + SHIFT + 4", hl.dsp.exec_cmd("hyprshot -m region"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 10"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 10"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -m"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), { locked = true, repeating = true })

hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

hl.bind("SUPER + ALT + right", hl.dsp.window.resize({ x = 100, y = 0 }))
hl.bind("SUPER + ALT + left", hl.dsp.window.resize({ x = -100, y = 0 }))
hl.bind("SUPER + ALT + up", hl.dsp.window.resize({ x = 0, y = -100 }))
hl.bind("SUPER + ALT + down", hl.dsp.window.resize({ x = 0, y = 100 }))

hl.bind("SUPER + code:35", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + code:38", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + code:37", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + code:36", hl.dsp.focus({ direction = "down" }))

hl.bind("SUPER + SHIFT + code:35", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + code:38", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + code:37", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + code:36", hl.dsp.window.move({ direction = "down" }))

hl.bind("SUPER + ALT + code:35", hl.dsp.window.resize({ x = 100, y = 0 }))
hl.bind("SUPER + ALT + code:38", hl.dsp.window.resize({ x = -100, y = 0 }))
hl.bind("SUPER + ALT + code:37", hl.dsp.window.resize({ x = 0, y = -100 }))
hl.bind("SUPER + ALT + code:36", hl.dsp.window.resize({ x = 0, y = 100 }))

for i = 1, 10 do
    local key = i % 10
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
