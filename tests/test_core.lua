local utils = require("tests.config.utils")

local equal = MiniTest.expect.equality

describe("nightjungle.nvim core funtionality", function()
  local nvim = {}

  setup(function()
    nvim = MiniTest.new_child_neovim()
  end)

  before_each(function()
    utils.new_instance(nvim)
    nvim.lua([[
			vim.cmd("colorscheme nightjungle")
			vim.cmd(":e tests/files/text.txt")
    ]])
  end)

  after_each(function()
    nvim.lua([[
			require("nightjungle").clean()
    ]])
  end)

  it("should load with no errors", function()
    local content = nvim.lua_get([[vim.fn.getline(1, "$")]])
    equal("nightjungle.nvim", content[1])
  end)

  it("should set the colors_name variable", function()
    local colors_name = nvim.lua_get([[vim.g.colors_name]])
    equal("nightjungle", colors_name)
  end)

  it("should apply the color highlights", function()
    local err = nvim.lua_get([[vim.api.nvim_exec("hi ErrorMsg", true)]])
    equal("ErrorMsg       xxx guifg=#ca2f50", err)

    local normalFloat = nvim.lua_get([[vim.api.nvim_exec("hi NormalFloat ", true)]])
    equal("NormalFloat    xxx guifg=#a4acb8 guibg=#000000", normalFloat)
  end)

  it("should apply filetype highlights", function()
    local output = nvim.lua_get([[vim.api.nvim_exec("hi @type.javascript", true)]])
    equal("@type.javascript xxx guifg=#0a7868", output)
  end)

  it("should apply plugin highlights", function()
    local output = nvim.lua_get([[vim.api.nvim_exec("hi BlinkCmpMenuSelection ", true)]])
    equal("BlinkCmpMenuSelection xxx cterm=bold gui=bold guifg=#000000 guibg=#005869", output)
  end)

  teardown(function()
    nvim.stop()
  end)
end)
