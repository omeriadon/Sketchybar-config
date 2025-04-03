local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain
sbar.default({
  
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 13.0
    },
    color = colors.white,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
    background = { image = { corner_radius = 9 } },
  },
  label = {
    color = colors.transparent,
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 13.0
    },
    color = colors.white,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
    blur_radius = 20,
  },
  background = {
    
    height = 27,
    corner_radius = 6,
    border_width = 2,
    border_color = colors.bg2,
    image = {
      corner_radius = 9,
      border_color = colors.grey,
      border_width = 1
    }
  
  },
  popup = {
    background = {
      color = colors.white,
      border_width = 1, -- Changed from 2px to 1px
      corner_radius = 9,
      border_color = colors.popup.border,
      color = colors.popup.bg,
      shadow = { drawing = true },
    },
    blur_radius = 5,
  },
  padding_left = 5,
  padding_right = 5,
  scroll_texts = true,
})
