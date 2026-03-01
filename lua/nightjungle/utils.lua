local M = {}

---Recursively copy a Lua value.
---@param value any
---@return any
function M.deepcopy(value)
  if type(value) ~= "table" then
    return value
  end

  local copied = {}
  for key, item in pairs(value) do
    copied[key] = M.deepcopy(item)
  end

  return copied
end

---Deep merge two tables, preferring override values.
---@param base table
---@param override any
---@return table
function M.merge_tables(base, override)
  local merged = M.deepcopy(base)
  if type(override) ~= "table" then
    return merged
  end

  for key, value in pairs(override) do
    if type(value) == "table" and type(merged[key]) == "table" then
      merged[key] = M.merge_tables(merged[key], value)
    else
      merged[key] = M.deepcopy(value)
    end
  end

  return merged
end

---Join path fragments with a slash.
---@param ... string
---@return string
function M.join_paths(...)
  return table.concat({ ... }, "/")
end

---Ensure a directory exists.
---@param path string
---@return nil
function M.ensure_dir(path)
  vim.fn.mkdir(path, "p")
end

---Check whether a path exists.
---@param path string
---@return boolean
function M.exists(path)
  return vim.fn.filereadable(path) == 1
end

---Read a file as a full string.
---@param path string
---@return string|nil
function M.read(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end

  local content = f:read("*a")
  f:close()
  return content
end

---Write content to a file path.
---@param path string
---@param content string
---@return file*|nil
function M.write(path, content)
  local f = io.open(path, "wb")
  if not f then
    return nil
  end

  f:write(content)
  f:close()
  return f
end

return M
