local cfg = require("nightjungle.config")
local highlight = require("nightjungle.highlight")

local M = {
  theme = "nightjungle",
  is_setup = false,
}

---Setup the Nightjungle theme configuration and apply highlights.
---@param opts? table
---@return nil
function M.setup(opts)
  opts = opts or {}

  if vim.g.colors_name then
    vim.cmd("hi clear")
  end

  vim.o.termguicolors = true

  cfg.setup(opts)
  M.config = cfg.config

  local groups = highlight.groups(M.config)
  highlight.apply(groups, M.config.palette)

  vim.g.colors_name = M.theme

  M.is_setup = true
end

return setmetatable(M, {
  __index = function(_, key)
    if key == "setup" then
      return M.setup
    end

    local config = rawget(M, "config")
    if type(config) ~= "table" then
      return nil
    end

    return rawget(config, key)
  end,
})
