local Config = require("gline.config")
local Colors = require("gline.colors")

---Used to make complete tab entries in the tabline. :make(tab) will return a string
---for that tabs information based on the users config
---@class Gline.EntryFactory
---@field component_factory GLine.ComponentFactory
local EntryFactory = {}
EntryFactory.__index = EntryFactory

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
---@return Gline.EntryFactory
function EntryFactory:new(component_factory)
  local entry = setmetatable({}, EntryFactory)
  entry.component_factory = component_factory
  return entry
end

---@param tab TabInfo
---@return string string representation of a tab in the tabline
function EntryFactory:make(tab)
  local separator = Config.separator.enabled and self.component_factory:separator(tab) or ""
  local ft_icon = Config.ft_icon.enabled and self.component_factory:ft_icon(tab) or ""
  local name = Config.name.enabled and self.component_factory:name(tab) or ""
  local modified = Config.modified.enabled and self.component_factory:modified(tab) or ""

  local components = { separator, ft_icon, name, modified }
  local left_padding, right_padding = get_padding(table.concat(components)) -- TODO: iteratively increase width in Entry instead of this

  return (tab.is_selected and Colors.sel or Colors.norm)
    .. separator
    .. left_padding
    .. ft_icon
    .. " "
    .. name
    .. " "
    .. modified
    .. right_padding
end

return EntryFactory
