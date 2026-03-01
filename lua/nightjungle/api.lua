local config = require("nightjungle.config")
local palette = require("nightjungle.palette")

local M = {}

---Return the active Nightjungle palette as key/value pairs.
---@return table<string, string>
function M.get_colors()
  local active = type(config.config) == "table" and config.config.palette or nil
  if type(active) == "table" and next(active) ~= nil then
    return vim.deepcopy(active)
  end

  return vim.deepcopy(palette)
end

return M
