local config = require("nightjungle.config")
local highlight_groups = require("nightjungle.highlight")

local M = {}

---Parse a comma separated styles or table values into a table.
---@param tbl table
---@return table
local function parse_style(tbl)
  if not tbl.style then
    return tbl
  elseif tbl.style == "NONE" then
    tbl.style = nil
    return tbl
  end

  for token in string.gmatch(tbl.style, "([^,]+)") do
    tbl[token] = true
  end

  tbl.style = nil

  return tbl
end

---Expand the highlight group's values into a string from a table.
---@param tbl table
---@return string
local function expand_values(tbl)
  local values = {}
  for k, v in pairs(tbl) do
    local q = type(v) == "string" and [["]] or ""
    if k ~= "ns_id" then
      table.insert(values, string.format([[%s = %s%s%s]], k, q, v, q))
    end
  end

  table.sort(values)
  return string.format([[{ %s }]], table.concat(values, ", "))
end

---Resolve a color in a highlight group by palette token.
---@param value any
---@param palette table<string, string>
---@return any
local function resolve_value(value, palette)
  if type(value) ~= "string" then
    return value
  end

  return palette[value] or value
end

---Create highlight groups using the Neovim API.
---@param name string
---@param values table
---@param palette table<string, string>
---@return string
local function highlight(name, values, palette)
  if values.link then
    return string.format([[set_hl(0, "%s", { link = "%s" })]], name, values.link)
  end

  if next(values) == nil then
    return string.format([[set_hl(%s, "%s", {})]], values.ns_id or 0, name)
  end

  local val = parse_style(vim.deepcopy(values))
  val.bg = resolve_value(values.bg, palette)
  val.fg = resolve_value(values.fg, palette)
  val.sp = resolve_value(values.sp, palette)

  return string.format([[set_hl(%s, "%s", %s)]], values.ns_id or 0, name, expand_values(val))
end

---Compile the theme.
---@param _theme string|nil
---@param opts? table
---@return function|string
function M.compile(_theme, opts)
  local groups = highlight_groups.groups(config.config)
  local palette = config.config.palette

  local lines = {
    [[
return string.dump(function()
local set_hl = vim.api.nvim_set_hl

if vim.g.colors_name then vim.cmd("hi clear") end

vim.o.termguicolors = true
vim.g.colors_name = "nightjungle"]],
  }

  table.insert(lines, "\n-- Highlight groups\n")
  for name, values in pairs(groups) do
    table.insert(lines, highlight(name, values, palette))
  end

  table.insert(lines, [[end)]])

  if opts and opts.debug then
    return table.concat(lines, "\n")
  end

  local ld = load or loadstring
  return assert(ld(table.concat(lines, "\n"), "="))()
end

return M
