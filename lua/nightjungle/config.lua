local base_palette = require("nightjungle.palette")
local utils = require("nightjungle.utils")

local M = {}

M.defaults = {
  cache_path = vim.fn.expand(vim.fn.stdpath("cache") .. "/nightjungle"), -- The path to the cache directory
  cache_suffix = "_compiled",
  filetypes = { -- Enable/disable specific plugins
    -- c = true,
    -- comment = true,
    -- go = true,
    -- html = true,
    -- java = true,
    -- javascript = true,
    -- json = true,
    -- latex = true,
    -- lua = true,
    -- markdown = true,
    -- php = true,
    -- python = true,
    -- ruby = true,
    -- rust = true,
    -- scss = true,
    -- toml = true,
    -- typescript = true,
    -- typescriptreact = true,
    -- vue = true,
    -- xml = true,
    -- yaml = true,
  },
  highlights = {}, -- Add/override highlights
  options = {
    transparency = false, -- Use a transparent background?
  },
  palette = {},
  plugins = {},
}

---Apply filetype/plugin boolean overrides to a defaults table.
---@param files table<string, boolean>
---@param override table<string, boolean>
---@return table<string, boolean>
local function load_files(files, override)
  if type(files) ~= "table" or type(override) ~= "table" then
    return files
  end

  for file, _ in pairs(files) do
    if override.all == false then
      files[file] = false
    end

    if override[file] ~= nil then
      files[file] = override[file]
    end
  end

  return files
end

---Normalize user options into a validated configuration table.
---@param opts? table
---@return table
function M.normalize(opts)
  local input = type(opts) == "table" and opts or {}
  local raw_palette = type(input.palette) == "table" and input.palette or {}
  local palette_overrides = {}

  for token, value in pairs(raw_palette) do
    if base_palette[token] ~= nil and type(value) == "string" then
      palette_overrides[token] = value
    end
  end

  return {
    styles = utils.merge_tables(M.defaults.styles, input.styles),
    palette = utils.merge_tables(base_palette, palette_overrides),
    highlights = utils.merge_tables(M.defaults.highlights, input.highlights),
    filetypes = utils.merge_tables(M.defaults.filetypes, input.filetypes),
    options = utils.merge_tables(M.defaults.options, input.options),
    plugins = utils.merge_tables(M.defaults.plugins, input.plugins),
  }
end

---Build and store plugin configuration from defaults and user options.
---@param opts? table
---@return nil
function M.setup(opts)
  opts = opts or {}

  local config = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts)
  M.config = M.normalize(config)

  if opts.filetypes then
    M.config.filetypes = load_files(M.config.filetypes, opts.filetypes)
  end

  if opts.plugins then
    M.config.plugins = load_files(M.config.plugins, opts.plugins)
  end
end

return M
