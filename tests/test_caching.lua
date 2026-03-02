local utils = require("tests.config.utils")

local equal = MiniTest.expect.equality
local not_equal = MiniTest.expect.no_equality

describe("nightjungle.nvim caching", function()
  local nvim = {}

  setup(function()
    nvim = MiniTest.new_child_neovim()
  end)

  before_each(function()
    utils.new_instance(nvim)
    nvim.lua([[
			local nightjungle = require("nightjungle")
			nightjungle.setup({
					cache_path = vim.fn.expand(vim.fn.stdpath("cache") .. "/nightjungle_test"),
			})

			vim.cmd("colorscheme nightjungle")
			vim.cmd(":e tests/files/text.txt")

			local util = require("nightjungle.utils")
			local config = require("nightjungle.config")
			local cache_path, compiled_path = config.get_cached_info()
			local hash_path = util.join_paths(cache_path, "cache")

			vim.g.nightjungle_cache_content = util.read(hash_path)
			vim.g.nightjungle_compiled_content = util.read(compiled_path)
    ]])
  end)

  after_each(function()
    nvim.lua([[
      require("nightjungle").clean()
    ]])
  end)

  it("should not regenerate a hash if it doesn't need to", function()
    local original_cache_content = nvim.lua_get([[vim.g.nightjungle_cache_content]])
    local current_hash = nvim.lua([[
			local util = require("nightjungle.utils")
			vim.cmd("colorscheme nightjungle")
			local cache_path = require("nightjungle.config").get_cached_info()
			return util.read(util.join_paths(cache_path, "cache"))
		]])
    equal(original_cache_content, current_hash)
  end)

  it("should not regenerate colorschemes if it doesn't need to", function()
    local original_compiled_content = nvim.lua_get([[vim.g.nightjungle_compiled_content]])
    local current_nightjungle = nvim.lua([[
			local util = require("nightjungle.utils")
			vim.cmd("colorscheme nightjungle")
			local _, compiled_path = require("nightjungle.config").get_cached_info()
			return util.read(compiled_path)
		]])
    equal(original_compiled_content, current_nightjungle)
  end)

  it("should return the same hash for the same table", function()
    local hashes = nvim.lua([[
			local hash = require("nightjungle.lib.hash").hash
			local tbl = {
				colors = {},
				highlights = {},
				filetypes = {
					javascript = true,
					lua = true,
					markdown = true,
					php = true,
					python = true,
					ruby = true,
					rust = true,
					toml = true,
					typescript = true,
					typescriptreact = true,
					vue = true,
					yaml = true,
				},
			}

			return {
				original = hash(tbl),
				repeated = hash(tbl),
			}
    ]])

    equal(hashes.original, hashes.repeated)
  end)

  it("should return a different hash for a modified table", function()
    local hashes = nvim.lua([[
			local hash = require("nightjungle.lib.hash").hash
			local tbl = {
				colors = {},
				highlights = {},
				filetypes = {
					javascript = true,
					lua = true,
					markdown = true,
					python = true,
					php = true,
					ruby = true,
					rust = true,
					toml = true,
					typescript = true,
					typescriptreact = true,
					vue = true,
					yaml = true,
				},
			}

			local original = hash(tbl)
			tbl.colors = {
				red = "#ff0000",
			}

			return {
				original = original,
				modified = hash(tbl),
			}
    ]])

    not_equal(hashes.original, hashes.modified)
  end)

  teardown(function()
    nvim.stop()
  end)
end)
