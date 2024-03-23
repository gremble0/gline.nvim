local Config = require("gline.config")

---@class GlineEntryFactory
---@field component_factory GLineComponentFactory
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

  local left_padding = (" "):rep(math.floor(total_padding / 2))
  local right_padding = (" "):rep(math.ceil(total_padding / 2))

  return left_padding, right_padding
end

---@param component_factory GLineComponentFactory
---@return GlineEntryFactory
function EntryFactory:new(component_factory)
  local entry = setmetatable({}, EntryFactory)
  entry.component_factory = component_factory
  return entry
end

---@param tab Tab
---@return string
function EntryFactory:make(tab)
  local separator = Config.separator.enabled and self.component_factory:separator(tab) or ""
  local ft_icon = Config.ft_icon.enabled and self.component_factory:ft_icon(tab) or ""
  local name = Config.name.enabled and self.component_factory:name(tab) or ""
  local modified = Config.modified.enabled and self.component_factory:modified(tab) or ""

  local entry = separator .. ft_icon .. " " .. name .. " " .. modified
  local left_padding, right_padding = get_padding(entry)

  return separator .. left_padding .. ft_icon .. " " .. name .. " " .. modified .. right_padding
end

return EntryFactory
