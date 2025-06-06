local settings = require("settings")
local colors = require("colors")

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

local cal = sbar.add("item", {
  icon = {
    color = colors.white,
    padding_left = 8,
    font = {
      style = settings.font.style_map["Black"],
      size = 12.0,
    },
  },
  label = {
    color = colors.white,
    padding_right = 8,
    width = 80,
    align = "right",
    font = { family = settings.font.numbers },
  },
  position = "right",
  update_freq = 30,
  padding_left = 1,
  padding_right = 1,
  background = {
    -- color = colors.bg2,
    border_color = colors.black,
    border_width = 0.5
    
  },
  
  click_script = "osascript -e 'tell application \"System Events\" to keystroke \"n\" using {option down, shift down, command down}'"
})

-- Double border for calendar using a single item bracket
sbar.add("bracket", { cal.name }, {
  background = {
    color = colors.transparent,
    height = 27,
    border_color = colors.white,
    border_width = 0,
    corner_radius = 12,
  }
})

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
  cal:set({ icon = os.date("%a. %d %b."), label = os.date("%H:%M") })
end)

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
  cal:set({
      icon = os.date("%a. %d %b."), label = os.date("%I:%M %p")
  })
end)