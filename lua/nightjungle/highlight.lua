local M = {}

---Convert a Lua file path into a require-able module path.
---@param path string
---@return string|nil
local function path_to_module(path)
  local module = path:match("lua/(.*)%.lua$")
  if not module then
    return nil
  end

  return module:gsub("/", ".")
end

---Load and merge highlight group tables from runtime files.
---@param pattern string
---@return table<string, table>
function M.load_groups(pattern)
  local groups = {}
  local files = vim.api.nvim_get_runtime_file(pattern, true)
  table.sort(files)

  for _, file in ipairs(files) do
    local module = path_to_module(file)
    if module then
      local ok, loaded = pcall(require, module)
      if ok and type(loaded) == "table" then
        groups = vim.tbl_deep_extend("force", groups, loaded)
      end
    end
  end

  return groups
end

---Build the final highlight groups from defaults and user overrides.
---@param config table
---@return table<string, table>
function M.groups(config)
  local core = M.load_groups("lua/nightjungle/highlights/core/*.lua")
  return vim.tbl_deep_extend("force", core, config.highlights or {})
end

---Resolve palette token references to concrete highlight values.
---@param value any
---@param palette table<string, string>
---@return any
local function resolve_color(value, palette)
  if type(value) ~= "string" then
    return value
  end

  return palette[value] or value
end

---Apply highlight groups through the Neovim API.
---@param groups table<string, table>
---@param palette table<string, string>
---@return nil
function M.apply(groups, palette)
  for name, values in pairs(groups) do
    if values.link then
      vim.api.nvim_set_hl(0, name, { link = values.link })
    else
      local highlight = {}
      for key, value in pairs(values) do
        if key == "fg" or key == "bg" or key == "sp" then
          highlight[key] = resolve_color(value, palette)
        else
          highlight[key] = value
        end
      end

      vim.api.nvim_set_hl(0, name, highlight)
    end
  end
end

return M
