return {
  {
    cmd = "NightJungleBGToggle",
    callback = function()
      local nightjungle = require("nightjungle")
      local transparent = nightjungle.toggle_background()
      local mode = transparent and "transparent" or "solid"
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
      local _, count = nightjungle.open_colors()
      if count == 0 then
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
