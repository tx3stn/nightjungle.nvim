local base_palette = require("nightjungle.palette")
local utils = require("nightjungle.utils")

local M = {
  theme = "nightjungle",
  config = {},
  is_setup = false,
}

M.defaults = {
  caching = true,
  cache_path = vim.fn.expand(vim.fn.stdpath("cache") .. "/nightjungle"), -- The path to the cache directory
  cache_suffix = "_compiled",
  debug = false,
  filetypes = { -- Enable/disable specific plugins
    bash = true,
    c = true,
    comment = true,
    dockerfile = true,
    go = true,
    hcl = true,
    html = true,
    java = true,
    javascript = true,
    json = true,
    latex = true,
    lua = true,
    markdown = true,
    php = true,
    python = true,
    ruby = true,
    rust = true,
    scss = true,
    terraform = true,
    toml = true,
    tsx = true,
    typescript = true,
    vue = true,
    xml = true,
    yaml = true,
  },
  highlights = {}, -- Add/override highlights
  options = {
    transparency = false, -- Use a transparent background?
  },
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = { bold = true },
    strings = {},
  },
  palette = {},
  plugins = {
    blink = true,
    lazy = true,
    lspsaga = true,
    markview = true,
    mason = true,
    moody = true,
    neotest = true,
    nvimtree = true,
    oil = true,
    snacks = true,
    telescope = true,
  },
}

M.config = vim.deepcopy(M.defaults)

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
    caching = input.caching ~= nil and input.caching or M.defaults.caching,
    cache_path = type(input.cache_path) == "string" and input.cache_path or M.defaults.cache_path,
    cache_suffix = type(input.cache_suffix) == "string" and input.cache_suffix or M.defaults.cache_suffix,
    debug = input.debug == true,
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
  M.config.filetypes = load_files(M.config.filetypes, opts.filetypes)
  M.config.plugins = load_files(M.config.plugins, opts.plugins)
  M.is_setup = true
end

---Get information relating to where the cache is stored.
---@param opts? table
---@return string,string
function M.get_cached_info(opts)
  opts = opts or {}

  local theme = opts.theme or M.theme
  local cache_path = opts.cache_path or M.config.cache_path
  local theme_path = utils.join_paths(cache_path, theme .. M.config.cache_suffix)

  return cache_path, theme_path
end

---Create a hash from the config.
---@return string|number
function M.hash()
  local hash = require("nightjungle.lib.hash").hash(M.config)
  return hash and hash or 0
end

return M
