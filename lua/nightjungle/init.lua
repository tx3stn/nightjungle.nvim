local cfg = require("nightjungle.config")
local palette = require("nightjungle.palette")
local util = require("nightjungle.utils")
local commands = require("nightjungle.commands")
local cache = require("nightjungle.lib.cache")
local compiler = require("nightjungle.lib.compile")

local M = {
  theme = "nightjungle",
  is_setup = false,
}

local commands_registered = false

---Register user commands once per session.
---@return nil
local function register_commands()
  if commands_registered then
    return
  end

  if type(vim) ~= "table" or not vim.api or type(vim.api.nvim_create_user_command) ~= "function" then
    return
  end

  for _, cmd in ipairs(commands) do
    pcall(vim.api.nvim_create_user_command, cmd.cmd, cmd.callback, cmd.opts)
  end

  commands_registered = true
end

---Compile all themes and cache them.
---@return nil
function M.cache()
  cache.write({
    theme = cfg.theme,
    cache = compiler.compile(cfg.theme),
  })

  if cfg.config.debug then
    cache.write({
      theme = cfg.theme,
      cache = compiler.compile(cfg.theme, { debug = true }),
      suffix = "_debug",
    })
  end
end

---Clean all cache files.
---@return nil
function M.clean()
  cache.clean({ theme = cfg.theme })
  cache.clean({ file = "cache" })
end

---Return the active Nightjungle palette as key/value pairs.
---@return table<string, string>
function M.get_colors()
  local active = type(cfg.config) == "table" and cfg.config.palette or nil
  if type(active) == "table" and next(active) ~= nil then
    return vim.deepcopy(active)
  end

  return vim.deepcopy(palette)
end

---Toggle transparency mode and reload the theme.
---@return boolean transparency_enabled
function M.toggle_background()
  local conf = M.get_config() or {}
  local options = conf.options or {}

  options.transparency = not (options.transparency == true)
  conf.options = options

  M.cache()
  M.load()

  return options.transparency == true
end

---Open a scratch buffer with the active palette values.
---@return integer buffer
---@return integer color_count
function M.open_colors()
  local colors = M.get_colors()
  local tokens = {}

  for token, value in pairs(colors) do
    if type(token) == "string" and type(value) == "string" then
      tokens[#tokens + 1] = token
    end
  end

  table.sort(tokens)

  local lines = {}
  for _, token in ipairs(tokens) do
    lines[#lines + 1] = string.format("%-28s %s", token, colors[token])
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_set_option_value("readonly", true, { buf = buf })
  vim.api.nvim_set_current_buf(buf)

  return buf, #lines
end

---Determine if the cache is valid or if it needs to be regenerated.
---@return nil
local function validate_cache()
  util.ensure_dir(cfg.config.cache_path)

  local hash_path = util.join_paths(cfg.config.cache_path, "cache")

  local source = debug.getinfo(1, "S").source
  local module_path = type(source) == "string" and source:sub(1, 1) == "@" and source:sub(2) or ""
  local repo_root = module_path:match("^(.*)/lua/nightjungle/init%.lua$") or ""
  local git_path = util.join_paths(repo_root, ".git")
  local git = vim.fn.getftime(git_path)
  local cached_hash = cfg.hash() .. (git == -1 and git_path or git)

  if cached_hash ~= util.read(hash_path) then
    M.cache()
    util.write(hash_path, cached_hash)
  end
end

---Setup the Nightjungle theme configuration.
---@param opts? table
---@return nil
function M.setup(opts)
  opts = opts or {}

  cfg.setup(opts)
  register_commands()

  if not cfg.config.caching or cfg.config.debug then
    return M.cache()
  end

  validate_cache()

  M.config = cfg.config

  M.is_setup = true
end

---Load the compiled theme cache.
---@param opts? table
---@return nil
function M.load(opts)
  if not cfg.is_setup then
    cfg.setup(opts)
    validate_cache()
  end

  register_commands()

  local _, cached_theme = cfg.get_cached_info(opts)
  if not util.exists(cached_theme) then
    M.cache()
  end

  local ok, theme = pcall(loadfile, cached_theme)
  if not ok then
    error("[nightjungle] Could not load the cache file")
  end

  if theme then
    theme()
  end

  M.config = cfg.config
  M.is_setup = true
end

---Get the active theme configuration.
---@return table
function M.get_config()
  return cfg.config
end

return setmetatable(M, {
  __index = function(_, key)
    if key == "setup" then
      return M.setup
    end

    if key == "load" then
      return M.load
    end

    local config = rawget(cfg, "config")
    if type(config) ~= "table" then
      return nil
    end

    return rawget(config, key)
  end,
})
