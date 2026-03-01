local cfg = require("nightjungle.config")
local util = require("nightjungle.utils")
local commands = require("nightjungle.commands")

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
  local cache = require("nightjungle.lib.cache")
  local compiler = require("nightjungle.lib.compile")

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
  local cache = require("nightjungle.lib.cache")

  cache.clean({ theme = cfg.theme })
  cache.clean({ file = "cache" })
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
