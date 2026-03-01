local uv = vim.uv or vim.loop

local M = {
  module = "nightjungle",
  colorscheme = "nightjungle",
  opts = {},
}

local function reload()
  for k in pairs(package.loaded) do
    if k:find("^" .. M.module) then
      package.loaded[k] = nil
    end
  end
  require(M.module).setup(M.opts)
  local colorscheme = vim.g.colors_name or M.colorscheme
  colorscheme = colorscheme:find(M.colorscheme) and colorscheme or M.colorscheme
  vim.cmd.colorscheme(colorscheme)
end
reload = vim.schedule_wrap(reload)

local augroup = vim.api.nvim_create_augroup("colorscheme_dev", { clear = true })
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  group = augroup,
  callback = reload,
})
vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup,
  pattern = "*/lua/" .. M.module .. "/**.lua",
  callback = reload,
})

return {
  {
    dir = vim.fn.getcwd(),
    name = "nightjungle.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      if not uv.fs_stat(vim.fn.getcwd() .. "/lua/" .. M.module) then
        return
      end

      reload()
    end,
  },
}
