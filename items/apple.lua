local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Padding item required because of bracket
sbar.add("item", { width = 5 })

local apple = sbar.add("item", {
  icon = {
    font = { size = 20.0 },
    string = icons.apple,
    padding_right = 8,
    padding_left = 8,
  },
  label = { drawing = false },
  padding_left = 1,
  padding_right = 1,
  popup = { align = "center", height = 35 },
  click_script = "open -a 'System Settings'"
})

-- Create the popup items
local apple_prefs = sbar.add("item", {
  position = "popup." .. apple.name,
  icon = { 
    string = "􀺽",  -- System settings icon
    color = colors.white
  },
  label = { 
    string = "System Settings",
    color = colors.white
  },
  click_script = [[
    open -a 'System Settings'
    sketchybar --set apple popup.drawing=off
  ]]
})

local apple_about = sbar.add("item", {
  position = "popup." .. apple.name,
  icon = { 
    string = "􀅴",  -- Info icon 
    color = colors.white
  },
  label = { 
    string = "About This Mac",
    color = colors.white
  },
  click_script = [[
    osascript -e 'tell application "System Events" to tell process "Finder" to click menu item "About This Mac" of menu "Apple" of menu bar 1'
    sketchybar --set apple popup.drawing=off
  ]]
})

-- Function to hide popup when mouse leaves
local function hide_popup()
  apple:set({ popup = { drawing = false } })
end

-- Handle click events
apple:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    apple:set({ popup = { drawing = "toggle" } })
  end
end)

-- Hide popup when mouse leaves the bar
apple:subscribe("mouse.exited.global", hide_popup)

-- Double border for apple using a single item bracket
sbar.add("bracket", { apple.name }, {
  background = {
    color = colors.transparent,
    height = 30,
    border_color = colors.white,
    border_width = 0,
    corner_radius = 11,
  }
})

-- Padding item required because of bracket
sbar.add("item", { width = 7 })
