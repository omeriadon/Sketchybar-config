local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

-- Define apps to show in the widget
local whitelist = { 
  ["Music"] = true
}

-- Simple music icon + title widget
local media_icon = sbar.add("item", "music.icon", {
  position = "right",
  icon = { 
    string = "􀑪", -- Music symbol for not playing
    font = { size = 16.0 },
    color = colors.grey,
    padding_right = 0, -- Removed padding between icon and title
  },
  padding_right = 10, -- Removed padding
  padding_left = 0,
})

local media_title = sbar.add("item", "music.title", {
  position = "right",
  padding_left = 0,
  padding_right = 0,
  icon = { drawing = false },
  label = {
    string = "Not playing",
    font = { size = 12.0 },
    color = colors.grey,
    max_chars = 25,
    scroll_duration = 100, -- Slower scrolling (default is typically 15-20)
  },
  update_freq = 1, -- Update every second
})

-- Calculate popup width (20% wider than before)
local popup_width = 500

-- Simple bracket with icon and title
local music_bracket = sbar.add("bracket", "music.bracket", { 
  media_icon.name, 
  media_title.name
}, {
  background = { 
    height = 26, 
    corner_radius = 6,
  },
  popup = { 
    align = "center",
    background = {
      corner_radius = 9,
      border_width = 1,
      border_color = colors.popup.border,
      color = colors.popup.bg,
      shadow = { drawing = true },
    },
    blur_radius = 5,
  }
})

-- Create custom events for handling music updates
sbar.add("event", "music_update")

-- Create popup items with consistent styling
local popup_title = sbar.add("item", {
  position = "popup." .. music_bracket.name,
  icon = { 
    string = "Title:",
    color = colors.white,
    font = {
      style = settings.font.style_map["Bold"],
      size = 13.0,
    },
    width = 60,
    align = "left",
  },
  label = {
    string = "Not playing",
    color = colors.white,
    font = {
      style = settings.font.style_map["Regular"],
      size = 13.0,
    },
    width = popup_width - 80, -- Dynamic width with padding
    align = "right",
  },
  width = popup_width,
})

local popup_artist = sbar.add("item", {
  position = "popup." .. music_bracket.name,
  icon = { 
    string = "Artist:",
    color = colors.white,
    font = {
      style = settings.font.style_map["Bold"],
      size = 13.0,
    },
    width = 60,
    align = "left",
  },
  label = {
    string = "-",
    color = colors.white,
    font = {
      style = settings.font.style_map["Regular"],
      size = 13.0,
    },
    width = popup_width - 80, -- Dynamic width with padding
    align = "right",
  },
  width = popup_width,
})

local popup_album = sbar.add("item", {
  position = "popup." .. music_bracket.name,
  icon = { 
    string = "Album:",
    color = colors.white,
    font = {
      style = settings.font.style_map["Bold"],
      size = 13.0,
    },
    width = 60,
    align = "left",
  },
  label = {
    string = "-",
    color = colors.white,
    font = {
      style = settings.font.style_map["Regular"],
      size = 13.0,
    },
    width = popup_width - 80, -- Dynamic width with padding
    align = "right",
  },
  width = popup_width,
})

local popup_separator = sbar.add("item", {
  position = "popup." .. music_bracket.name,
  background = {
    height = 1,
    color = colors.grey,
  },
  width = popup_width,
})

-- Controls container
local controls_container = sbar.add("item", {
  position = "popup." .. music_bracket.name,
  background = { drawing = false },
  width = popup_width,
})

-- Put all controls in a single horizontal line with even spacing
local controls_width = popup_width - 40 -- Allow for some padding
local button_width = controls_width / 3

-- Add horizontal playback controls all in one line
local media_prev = sbar.add("item", {
  position = "popup." .. music_bracket.name,
  icon = { string = "􀊎", font = { size = 20.0 }, color = colors.white, align = "center" },
  label = { drawing = false },
  width = button_width,
  click_script = "osascript -e 'tell application \"Music\" to previous track'; sketchybar --trigger music_update"
})

local media_playpause = sbar.add("item", {
  position = "popup." .. music_bracket.name,
  icon = { string = "􀊕", font = { size = 20.0 }, color = colors.white, align = "center" },
  label = { drawing = false },
  width = button_width,
  click_script = "osascript -e 'tell application \"Music\" to playpause'; sketchybar --trigger music_update"
})

local media_next = sbar.add("item", {
  position = "popup." .. music_bracket.name,
  icon = { string = "􀊐", font = { size = 20.0 }, color = colors.white, align = "center" },
  label = { drawing = false },
  width = button_width,
  click_script = "osascript -e 'tell application \"Music\" to next track'; sketchybar --trigger music_update"
})

-- Create a horizontal bracket for the controls to ensure they appear in one line
sbar.add("bracket", "music.controls.bracket", {
  media_prev.name,
  media_playpause.name,
  media_next.name
}, {
  background = { drawing = false },
  horizontal = true
})

-- Basic update function for music info
local function update_music_info(env)
  local app = env.INFO and env.INFO.app
  local state = env.INFO and env.INFO.state
  
  -- Only process whitelisted apps
  if app and whitelist[app] then
    local drawing = (state == "playing")
    
    if drawing then
      -- Update the title display
      media_icon:set({
        icon = {
          string = "􀫀", -- Playing music symbol
          color = colors.green
        }
      })
      
      media_title:set({ 
        label = { 
          string = env.INFO.title or "Unknown Track",
          color = colors.white
        }
      })
      
      -- Update popup details
      popup_title:set({ label = { string = env.INFO.title or "Unknown Track" } })
      popup_artist:set({ label = { string = env.INFO.artist or "-" } })
      popup_album:set({ label = { string = env.INFO.album or "-" } })
      
      -- Update play/pause icon
      media_playpause:set({ icon = { string = "􀊗" } }) -- pause icon
    else
      -- Not playing state
      media_icon:set({
        icon = {
          string = "􀑪", -- Not playing music symbol
          color = colors.grey
        }
      })
      
      media_title:set({ 
        label = { 
          string = "Not playing",
          color = colors.grey
        }
      })
      
      -- Update popup to show not playing
      popup_title:set({ label = { string = "Not playing" } })
      popup_artist:set({ label = { string = "-" } })
      popup_album:set({ label = { string = "-" } })
      
      -- Update play/pause icon
      media_playpause:set({ icon = { string = "􀊕" } }) -- play icon
    end
  else
    -- Fallback to AppleScript for getting music info if event doesn't provide it
    local info_script = [[
      try
        if application "Music" is running then
          tell application "Music"
            if player state is playing then
              set trackName to name of current track
              set albumName to album of current track
              set artistName to artist of current track
              return "playing|" & trackName & "|" & albumName & "|" & artistName
            else
              return "stopped|Not playing||"
            end if
          end tell
        end if
        return "stopped|Not playing||"
      on error errMsg
        return "error|" & errMsg & "||"
      end try
    ]]
    
    sbar.exec('osascript -e \'' .. info_script .. '\'', function(result)
      local status, track, album, artist = result:match("([^|]+)|([^|]+)|([^|]*)|([^|]*)")
      
      if status == "playing" then
        -- Update the title display
        media_icon:set({
          icon = {
            string = "􀫀", -- Playing music symbol
            color = colors.green
          }
        })
        
        media_title:set({ 
          label = { 
            string = track or "Unknown Track",
            color = colors.white
          }
        })
        
        -- Update popup details
        popup_title:set({ label = { string = track or "Unknown Track" } })
        popup_artist:set({ label = { string = artist or "-" } })
        popup_album:set({ label = { string = album or "-" } })
        
        -- Update play/pause icon
        media_playpause:set({ icon = { string = "􀊗" } }) -- pause icon
      else
        -- Not playing state
        media_icon:set({
          icon = {
            string = "􀑪", -- Not playing music symbol
            color = colors.grey
          }
        })
        
        media_title:set({ 
          label = { 
            string = "Not playing",
            color = colors.grey
          }
        })
        
        -- Update popup to show not playing
        popup_title:set({ label = { string = "Not playing" } })
        popup_artist:set({ label = { string = "-" } })
        popup_album:set({ label = { string = "-" } })
        
        -- Update play/pause icon
        media_playpause:set({ icon = { string = "􀊕" } }) -- play icon
      end
    end)
  end

  -- Dynamically resize the popup width if we have a long song name
  if status == "playing" and track then
    local estimated_width = string.len(track) * 8 -- Estimate width based on character count
    local dynamic_width = math.max(popup_width, estimated_width + 80) -- Add some padding
    
    popup_title:set({ width = dynamic_width })
    popup_artist:set({ width = dynamic_width })
    popup_album:set({ width = dynamic_width })
    popup_separator:set({ width = dynamic_width })
    controls_container:set({ width = dynamic_width })
    
    -- Update label widths for dynamic text
    popup_title:set({ label = { width = dynamic_width - 80 } })
    popup_artist:set({ label = { width = dynamic_width - 80 } })
    popup_album:set({ label = { width = dynamic_width - 80 } })
  end
end

-- Make sure our title label has proper scrolling configuration
media_title:set({
  label = {
    scroll = true,
    scroll_duration = 200, -- Slower scrolling
    scroll_gap = 20  -- Add spacing between scroll
  }
})

-- Subscribe to events for all widget parts
media_icon:subscribe({"media_change", "routine", "forced", "system_woke", "music_update"}, update_music_info)
media_title:subscribe({"media_change", "routine", "forced", "system_woke", "music_update"}, update_music_info)

-- Set up the update every second
media_title:set({ update_freq = 1 })
media_title:subscribe("routine", update_music_info)

-- Toggle popup when any part of the widget is clicked
music_bracket:subscribe("mouse.clicked", function(env)
  music_bracket:set({ popup = { drawing = "toggle" } })
end)

media_icon:subscribe("mouse.clicked", function(env)
  music_bracket:set({ popup = { drawing = "toggle" } })
end)

media_title:subscribe("mouse.clicked", function(env)
  music_bracket:set({ popup = { drawing = "toggle" } })
end)

-- Close popup when mouse leaves screen globally
music_bracket:subscribe("mouse.exited.global", function(env)
  music_bracket:set({ popup = { drawing = false } })
end)

-- Padding
sbar.add("item", "music.padding.right", { position = "right", width = settings.group_paddings })

-- Initial update
sbar.trigger("music_update")