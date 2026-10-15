--  ______     __     __   __     _____     ______
-- /\  == \   /\ \   /\ "-.\ \   /\  __-.  /\  ___\
-- \ \  __<   \ \ \  \ \ \-.  \  \ \ \/\ \ \ \___  \
--  \ \_____\  \ \_\  \ \_\\"\_\  \ \____-  \/\_____\
--   \/_____/   \/_/   \/_/ \/_/   \/____/   \/_____/
--
-- Loaded by hyprland.lua via require("binds") (HM extraLuaFiles, default.nix).
-- ambxst's hyprland.lua is loaded after this and may rebind the same keys.

local mainMod = "SUPER"
local terminal = "kitty"

local function key(k) return mainMod .. " + " .. k end

hl.bind(key("RETURN"), hl.dsp.exec_cmd(terminal))
-- hl.bind(key("N"), hl.dsp.exec_cmd("kitty --session .nvim_session"))
hl.bind(key("C"), hl.dsp.window.close())
hl.bind(key("M"), hl.dsp.exec_cmd("/home/rafael/.dotfiles/home/config/wlogout/wlogout.sh"))
hl.bind(key("E"), hl.dsp.exec_cmd("kitty -- yazi"))

-- Move focus with mainMod + vim motions
hl.bind(key("H"), hl.dsp.focus({ direction = "left" }))
hl.bind(key("L"), hl.dsp.focus({ direction = "right" }))
hl.bind(key("K"), hl.dsp.focus({ direction = "up" }))
hl.bind(key("J"), hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-10 on the AZERTY top row; SHIFT moves the active window
local azerty = {
  "ampersand", "eacute", "quotedbl", "apostrophe", "parenleft",
  "minus", "egrave", "underscore", "ccedilla", "agrave",
}
for i, k in ipairs(azerty) do
  hl.bind(key(k), hl.dsp.focus({ workspace = i }))
  hl.bind(key("SHIFT + " .. k), hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(key("SHIFT + S"), hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(key("mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(key("mouse_up"), hl.dsp.focus({ workspace = "e-1" }))

-- clipse
-- hl.bind(key("V"), hl.dsp.exec_cmd("kitty --class clipse -e 'clipse'"))

-- vlock
-- hl.bind(key("SHIFT + L"), hl.dsp.exec_cmd("sudo vlock -an"))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(key("mouse:272"), hl.dsp.window.drag(), { mouse = true })
hl.bind(key("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness (old bindel)
local held = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), held)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), held)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), held)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), held)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), held)

-- Media keys, requires playerctl (old bindl)
local locked = { locked = true }
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), locked)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), locked)
