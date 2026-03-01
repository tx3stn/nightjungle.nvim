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

return M
