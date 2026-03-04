local M = {}

local STYLE_TARGETS = {
  comments = { "Comment", "@comment" },
  keywords = { "Keyword", "@keyword" },
  functions = { "Function", "@function", "@function.call", "@function.method" },
  strings = { "String", "@string" },
}

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

---Load and merge highlight groups for enabled named modules.
---@param prefix string
---@param enabled table<string, boolean>
---@return table<string, table>
local function load_enabled_groups(prefix, enabled)
  if type(enabled) ~= "table" then
    return {}
  end

  local groups = {}
  local names = {}

  for name, is_enabled in pairs(enabled) do
    if is_enabled then
      names[#names + 1] = name
    end
  end

  table.sort(names)

  for _, name in ipairs(names) do
    local ok, loaded = pcall(require, string.format("nightjungle.highlights.%s.%s", prefix, name))
    if ok and type(loaded) == "table" then
      groups = vim.tbl_deep_extend("force", groups, loaded)
    end
  end

  return groups
end

---Apply configured style flags to selected highlight groups.
---@param groups table<string, table>
---@param styles table<string, table>|nil
---@return table<string, table>
local function apply_styles(groups, styles)
  if type(styles) ~= "table" then
    return groups
  end

  for style_name, targets in pairs(STYLE_TARGETS) do
    local style_values = styles[style_name]
    if type(style_values) == "table" then
      for _, group in ipairs(targets) do
        if groups[group] then
          groups[group] = vim.tbl_deep_extend("force", groups[group], style_values)
        end
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
  local plugins = load_enabled_groups("plugins", config.plugins)
  local filetypes = load_enabled_groups("filetypes", config.filetypes)
  local groups = vim.tbl_deep_extend("force", core, plugins, filetypes, config.highlights or {})

  return apply_styles(groups, config.styles)
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
