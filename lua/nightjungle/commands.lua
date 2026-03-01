return {
  {
    cmd = "NightJungleBGToggle",
    callback = function()
      local nightjungle = require("nightjungle")
      local cfg = nightjungle.get_config() or {}
      local options = cfg.options or {}

      options.transparency = not (options.transparency == true)
      cfg.options = options

      nightjungle.cache()
      nightjungle.load()

      local mode = options.transparency and "transparent" or "solid"
      local ok, normal = pcall(vim.api.nvim_get_hl, 0, { name = "Normal", link = false })
      if ok and type(normal) == "table" then
        local bg = normal.bg and string.format("#%06X", normal.bg) or "NONE"
        vim.notify("nightjungle background: " .. mode .. " (Normal bg=" .. bg .. ")", vim.log.levels.INFO)
      else
        vim.notify("nightjungle background: " .. mode, vim.log.levels.INFO)
      end
    end,
    opts = {
      desc = "Toggle nightjungle transparent background",
      range = false,
    },
  },
  {
    cmd = "NightjungleColors",
    callback = function()
      local nightjungle = require("nightjungle")
      local cfg = nightjungle.get_config() or {}
      local palette = type(cfg.palette) == "table" and cfg.palette or {}

      local tokens = {}
      for token, value in pairs(palette) do
        if type(token) == "string" and type(value) == "string" then
          tokens[#tokens + 1] = token
        end
      end

      table.sort(tokens)

      local lines = {}
      for _, token in ipairs(tokens) do
        lines[#lines + 1] = string.format("%-28s %s", token, palette[token])
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

      if #lines == 0 then
        vim.notify("nightjungle: no active palette colors found", vim.log.levels.WARN)
      end
    end,
    opts = {
      desc = "Open nightjungle active color list",
      range = false,
    },
  },
  {
    cmd = "NightjungleCache",
    callback = function()
      local nightjungle = require("nightjungle")
      local ok, err = pcall(nightjungle.cache)
      if ok then
        vim.notify("nightjungle cache refreshed", vim.log.levels.INFO)
      else
        vim.notify(err or "nightjungle: failed to refresh cache", vim.log.levels.WARN)
      end
    end,
    opts = {
      desc = "Compile and write nightjungle cache",
      range = false,
    },
  },
  {
    cmd = "NightjungleCacheClear",
    callback = function()
      local nightjungle = require("nightjungle")
      local ok, err = pcall(nightjungle.clean)
      if ok then
        vim.notify("nightjungle cache cleared", vim.log.levels.INFO)
      else
        vim.notify(err or "nightjungle: failed to clear cache", vim.log.levels.WARN)
      end
    end,
    opts = {
      desc = "Clear nightjungle cache",
      range = false,
    },
  },
}
