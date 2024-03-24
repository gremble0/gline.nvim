local Config = require("gline.config")
local Colors = require("gline.colors")

---Used to make complete tab entries in the tabline. :make(tab) will return a string
---for that tabs information based on the users config
---@class Gline.TabFactory
---@field component_factory GLine.ComponentFactory
local TabFactory = {}
TabFactory.__index = TabFactory

---@param s string
---@return integer
local rendered_width = function(s)
  -- `#` or `:len()` will not be right here, as that counts bytes, not chars
  local len_iter = vim.fn.strchars(s)

  for highlight in s:gmatch("%%#.-#") do -- Matches inline hl groups like %#HighlightGroup#
    len_iter = len_iter - #highlight
  end

  return len_iter
end

---@param s string
---@return string left_padding, string right_padding
local get_padding = function(s)
  local total_padding = Config.entry_width - rendered_width(s)

  local left_padding = string.rep(" ", math.floor(total_padding / 2))
  local right_padding = string.rep(" ", math.ceil(total_padding / 2))

  return left_padding, right_padding
end

---@param component_factory GLine.ComponentFactory
---@return Gline.TabFactory
function TabFactory:new(component_factory)
  local entry = setmetatable({}, TabFactory)
  entry.component_factory = component_factory
  return entry
end

---@param tab TabInfo
---@return string string representation of a tab entry in the tabline
function TabFactory:make(tab)
  local components = {}
  if Config.separator.enabled then
    table.insert(components, self.component_factory:separator(tab))
  end
  if Config.ft_icon.enabled then
    table.insert(components, self.component_factory:ft_icon(tab))
  end
  if Config.name.enabled then
    table.insert(components, self.component_factory:name(tab))
  end
  if Config.modified.enabled then
    table.insert(components, self.component_factory:modified(tab))
  end

  local left_padding, right_padding = get_padding(table.concat(components, " ")) -- TODO: iteratively increase width in Entry instead of get_padding

  if Config.separator.enabled then
    table.insert(components, 2, left_padding)
  else
    table.insert(components, 1, left_padding)
  end
  table.insert(components, right_padding)

  return (tab.is_selected and Colors.sel or Colors.norm) .. table.concat(components, " ")
end

return TabFactory
