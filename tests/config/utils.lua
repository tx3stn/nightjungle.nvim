local M = {}

function M.new_instance(child)
  child.restart({ "-u", "tests/config/minimal.lua" })
  child.o.statusline = ""
  child.o.laststatus = 0
  child.o.cmdheight = 0
end

return M
