local utils = require("tests.config.utils")

local equal = MiniTest.expect.equality

describe("nightjungle.nvim config", function()
  local nvim = {}

  setup(function()
    nvim = MiniTest.new_child_neovim()
  end)

  before_each(function()
    utils.new_instance(nvim)
  end)

  after_each(function()
    nvim.lua([[
			require("nightjungle").clean()
    ]])
  end)

  it("should not apply javascript filetype highlight when filetype is disabled", function()
    local state = nvim.lua([[
			local before_ok, before_result = pcall(vim.api.nvim_exec, "hi @variable.builtin.javascript", true)

			local nightjungle = require("nightjungle")
			nightjungle.setup({
				cache_path = vim.fn.expand(vim.fn.stdpath("cache") .. "/nightjungle_test_config"),
				filetypes = {
					javascript = false,
				},
			})

			vim.cmd("colorscheme nightjungle")

			local after_ok, after_result = pcall(vim.api.nvim_exec, "hi @variable.builtin.javascript", true)
			return {
				before_ok = before_ok,
				before_result = before_result,
				after_ok = after_ok,
				after_result = after_result,
			}
    ]])

    equal(state.before_ok, state.after_ok)
    equal(state.before_result, state.after_result)
  end)

  it("should apply user highlight overrides", function()
    nvim.lua([[
			local nightjungle = require("nightjungle")

			nightjungle.setup({
				cache_path = vim.fn.expand(vim.fn.stdpath("cache") .. "/nightjungle_test_config"),
				highlights = {
					ErrorMsg = {
						fg = "#112233",
						bg = "#445566",
						bold = true,
					},
				},
			})

			vim.cmd("colorscheme nightjungle")
    ]])

    local output = nvim.lua_get([[vim.api.nvim_exec("hi ErrorMsg", true)]])
    equal("ErrorMsg       xxx cterm=bold gui=bold guifg=#112233 guibg=#445566", output)
  end)

  it("should apply user palette overrides", function()
    nvim.lua([[
			local nightjungle = require("nightjungle")

			nightjungle.setup({
				cache_path = vim.fn.expand(vim.fn.stdpath("cache") .. "/nightjungle_test_config"),
				palette = {
					["green.base"] = "#123456",
				},
			})

			vim.cmd("colorscheme nightjungle")
    ]])

    local output = nvim.lua_get([[vim.api.nvim_exec("hi Keyword", true)]])
    equal("Keyword        xxx guifg=#123456", output)
  end)

  teardown(function()
    nvim.stop()
  end)
end)
