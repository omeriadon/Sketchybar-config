require("items.apple")
require("items.spaces")
require("items.front_app")
require("items.calendar")
require("items.widgets")
require("items.music")

-- Check if center_music.lua exists before requiring it
local function file_exists(file)
   local f = io.open(file, "rb")
   if f then f:close() end
   return f ~= nil
end

-- Only include center_music if the file exists
if file_exists(os.getenv("HOME") .. "/.config/sketchybar/items/center_music.lua") then
  require("items.center_music")
end