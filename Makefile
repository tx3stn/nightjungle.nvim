.PHONY: deps format test

deps:
	@mkdir -p deps
	@test -d deps/nvim-treesitter || git clone --filter=blob:none https://github.com/nvim-treesitter/nvim-treesitter.git deps/nvim-treesitter
	@test -d deps/mini.nvim || git clone --filter=blob:none https://github.com/echasnovski/mini.nvim deps/mini.nvim

format:
	stylua lua 
	stylua --check lua

test: deps
	nvim --headless --noplugin -u ./tests/config/minimal.lua -c "lua MiniTest.run()"
