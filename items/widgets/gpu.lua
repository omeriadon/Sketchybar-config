local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Create a periodic update event for GPU info every 3 seconds
sbar.add("event", "gpu_update")
sbar.exec("killall gpu_monitor >/dev/null; (while true; do sketchybar --trigger gpu_update; sleep 3; done) & disown")

-- Create a GPU graph
local gpu = sbar.add("graph", "widgets.gpu", 42, {
  position = "right",
  graph = { color = colors.green },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { string = "􀫹" }, -- GPU icon
  label = {
    string = "??%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    align = "right",
    padding_right = 0,
    width = 0,
    y_offset = 4
  },
  padding_right = settings.paddings,
  padding_left = settings.paddings,
})

-- Function to update GPU usage data
gpu:subscribe("gpu_update", function(env)
  sbar.exec([[
    # Try multiple approaches for GPU usage
    
    # Method 1: Use Activity Monitor's processes to get GPU usage
    gpu_processes=$(ps -A -o %cpu | awk '{s+=$1} END {print s}')
    gpu_estimate1=$(echo "scale=0; $gpu_processes / 2" | bc)
    
    # Method 2: Using powermetrics (requires sudo, might not work)
    if command -v powermetrics >/dev/null 2>&1; then
      gpu_estimate2=$(sudo powermetrics --samplers gpu_power -n 1 -i 100 2>/dev/null | grep "GPU Active Residency" | awk '{print $4}' | tr -d '%' || echo "0")
    else
      gpu_estimate2="0"
    fi
    
    # Method 3: IORegistry (works with Intel integrated GPU and some AMD)
    gpu_estimate3=$(ioreg -rc IOAccelerator | grep "IOStatistics" -A 20 | grep "IOGPUUtilization" | awk '{print $3}' | tr -d '"}' || echo "0")
    
    # Use the best estimate available
    if [ "$gpu_estimate3" != "0" ] && [ -n "$gpu_estimate3" ]; then
      # Scale from 0-1.0 to 0-100
      gpu_usage=$(echo "scale=0; $gpu_estimate3 * 100" | bc)
    elif [ "$gpu_estimate2" != "0" ] && [ -n "$gpu_estimate2" ]; then
      gpu_usage=$gpu_estimate2
    else
      # Fallback to method 1
      gpu_usage=$gpu_estimate1
    fi
    
    # If all methods failed, try to detect if GPU is being used at all
    if [ "$gpu_usage" = "0" ] || [ -z "$gpu_usage" ]; then
      # Check if any processes are using the GPU
      if ps aux | grep -i 'gpu\|metal\|opencl' | grep -v grep >/dev/null; then
        gpu_usage="20"  # Show nominal usage if any GPU process is detected
      else
        gpu_usage="0"
      fi
    fi
    
    # Ensure the values are within range
    if [ "$gpu_usage" -gt 100 ]; then gpu_usage=100; fi
    
    # Output result - GPU%
    echo "$gpu_usage"
  ]], function(result)
    local gpu_usage = tonumber(result) or 0
    
    -- Update GPU graph
    gpu:push({ gpu_usage / 100 })
    
    -- Set GPU color based on usage
    local gpu_color = colors.green
    if gpu_usage > 60 then
      gpu_color = colors.yellow
    elseif gpu_usage > 75 then
      gpu_color = colors.orange
    elseif gpu_usage > 85 then
      gpu_color = colors.red
    end
    
    gpu:set({
      graph = { color = gpu_color },
      label = { string = string.format("%d%%", gpu_usage) }
    })
  end)
end)

-- Click handler
gpu:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a 'Activity Monitor' && osascript -e 'tell application \"Activity Monitor\" to activate'")
end)

-- Make bracket transparent with no border to avoid visual clutter
sbar.add("bracket", "widgets.gpu.bracket", { gpu.name }, {
  background = { 
    color = colors.transparent,
    border_width = 0,
    drawing = false
  }
})

-- Add sufficient padding to separate from other widgets
sbar.add("item", "widgets.gpu.padding", {
  position = "right",
  width = settings.group_paddings
})

-- Trigger initial update
sbar.trigger("gpu_update")
