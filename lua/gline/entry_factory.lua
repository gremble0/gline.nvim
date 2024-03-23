local config = require("gline.config").config

---@class GlineEntryFactory
---@field component_factory GLineComponentFactory
local EntryFactory = {}
EntryFactory.__index = EntryFactory

---@param component_factory GLineComponentFactory
---@return GlineEntryFactory
function EntryFactory:new(component_factory)
  local entry = setmetatable({}, EntryFactory)
  entry.component_factory = component_factory
  entry.entry = ""
  return entry
end

---@return integer
function EntryFactory:rendered_width()
  -- `#` or `:len()` will not be right here, as that counts bytes, not chars
  local len_iter = vim.fn.strchars(self.entry)

  for highlight in self.entry:gmatch("%%#.-#") do -- Matches inline hl groups like %#HighlightGroup#
    len_iter = len_iter - #highlight
  end

  return len_iter
end

---@return string left_padding, string right_padding
function EntryFactory:pad_to_width()
  local total_padding = config.entry_width - self:rendered_width()

  local left_padding = (" "):rep(math.floor(total_padding / 2))
  local right_padding = (" "):rep(math.ceil(total_padding / 2))

  return left_padding, right_padding
end

---@return string
function EntryFactory:make(tab)
  local separator = self.component_factory:separator(tab)
  local ft_icon = self.component_factory:ft_icon(tab)
  local name = self.component_factory:name(tab)
  local modified = self.component_factory:modified(tab)

  self.entry = separator .. ft_icon .. " " .. name .. " " .. modified
  local left_padding, right_padding = self:pad_to_width()

  return separator .. left_padding .. ft_icon .. " " .. name .. " " .. modified .. right_padding
end

return EntryFactory
