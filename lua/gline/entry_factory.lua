local Config = require("gline.config")

---@class GlineEntryFactory
---@field component_factory GLineComponentFactory
local EntryFactory = {}
EntryFactory.__index = EntryFactory

---@param component_factory GLineComponentFactory
---@return GlineEntryFactory
function EntryFactory:new(component_factory)
  local entry = setmetatable({}, EntryFactory)
  entry.component_factory = component_factory
  entry.entry = "" -- TODO: unnecessary?
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
  local total_padding = Config.config.entry_width - self:rendered_width()

  local left_padding = (" "):rep(math.floor(total_padding / 2))
  local right_padding = (" "):rep(math.ceil(total_padding / 2))

  return left_padding, right_padding
end

---@param tab integer
---@return string
function EntryFactory:make(tab)
  local separator = Config.config.separator.enabled and self.component_factory:separator(tab) or ""
  local ft_icon = Config.config.ft_icon.enabled and self.component_factory:ft_icon(tab) or ""
  local name = Config.config.name.enabled and self.component_factory:name(tab) or ""
  local modified = Config.config.modified.enabled and self.component_factory:modified(tab) or ""

  self.entry = separator .. ft_icon .. " " .. name .. " " .. modified
  local left_padding, right_padding = self:pad_to_width()

  return separator .. left_padding .. ft_icon .. " " .. name .. " " .. modified .. right_padding
end

return EntryFactory
