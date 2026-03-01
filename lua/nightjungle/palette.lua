local M = {
  ["bg.default"] = "#0e1216",
  ["bg.focus"] = "#0C0F13",
  ["bg.selected"] = "#020303",
  ["bg.dark"] = "#000000",
  ["fg.default"] = "#A4ACB8",
  ["fg.muted"] = "#778489",
  ["fg.dim"] = "#343A41",
  ["white.base"] = "#C5D1CC",
  ["gray.light"] = "#ABB2BF",
  ["blue.base"] = "#61AFEF",
  ["cyan.base"] = "#2FA8B2",
  ["purple.base"] = "#AA79E7",
  ["yellow.base"] = "#E6CD58",
  ["orange.base"] = "#E3A65E",
  ["red.base"] = "#CA2F50",
  ["green.base"] = "#005869",
  ["green.mid"] = "#0A7868",
  ["green.light"] = "#109868",
  ["green.soft"] = "#6AA892",
  ["diagnostic.error"] = false,
  ["diagnostic.warn"] = false,
  ["diagnostic.info"] = false,
  ["diagnostic.hint"] = false,
  ["diff.add"] = "#004A55",
  ["diff.delete"] = "#7A2A4A",
  ["diff.text"] = "#0A686D",
  ["git.add"] = false,
  ["git.change"] = "#AAA56F",
  ["git.delete"] = false,
  ["virtual_text.error"] = false,
  ["virtual_text.warn"] = false,
  ["virtual_text.info"] = false,
  ["virtual_text.hint"] = false,
}

local LINKS = {
  ["diagnostic.error"] = "red.base",
  ["diagnostic.warn"] = "yellow.base",
  ["diagnostic.info"] = "blue.base",
  ["diagnostic.hint"] = "cyan.base",
  ["git.add"] = "green.soft",
  ["git.delete"] = "red.base",
  ["virtual_text.error"] = "diagnostic.error",
  ["virtual_text.warn"] = "diagnostic.warn",
  ["virtual_text.info"] = "diagnostic.info",
  ["virtual_text.hint"] = "diagnostic.hint",
}

local function resolve(token, seen)
  local value = M[token]
  if value ~= false then
    return value
  end

  local source = LINKS[token]
  if not source then
    return nil
  end

  seen = seen or {}
  if seen[token] then
    return nil
  end
  seen[token] = true

  return resolve(source, seen)
end

for token in pairs(LINKS) do
  M[token] = resolve(token)
end

return M
