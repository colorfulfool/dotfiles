-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local function omarchy_kernel_option_enabled(expected_option)
  if type(io) ~= "table" or type(io.open) ~= "function" then return false end
  local opened, cmdline_file = pcall(io.open, "/proc/cmdline", "r")
  if not opened or not cmdline_file then return false end
  local read_ok, cmdline = pcall(cmdline_file.read, cmdline_file, "*a")
  pcall(cmdline_file.close, cmdline_file)
  if not read_ok or type(cmdline) ~= "string" then return false end
  for option in cmdline:gmatch("%S+") do if option == expected_option then return true end end
  return false
end

if omarchy_kernel_option_enabled("omarchy.qemu_virgl=1") then
  hl.config({ cursor = { invisible = true } })
  hl.on("hyprland.start", function() hl.exec_cmd("/usr/local/bin/omarchy-native-display-sync") end)
end

return {
  omarchy_kernel_option_enabled = omarchy_kernel_option_enabled
}
