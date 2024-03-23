---@class GLineEntry
---@field component_factory GLineComponentFactory
---@field config GlineConfig
local Entry = {}
Entry.__index = Entry

---@param component_factory GLineComponentFactory
---@return GLineEntry
function Entry:new(component_factory, config)
  local entry = setmetatable({}, Entry)
  entry.component_factory = component_factory
  entry.entry = ""
  entry.config = config
  return entry
end

---@return integer
function Entry:rendered_width()
  -- `#` or `:len()` will not be right here, as that counts bytes, not chars
  local len_iter = vim.fn.strchars(self.entry)

  for highlight in self.entry:gmatch("%%#.-#") do -- Matches inline hl groups like %#HighlightGroup#
    len_iter = len_iter - #highlight
  end

  return len_iter
end

---@return string left_padding, string right_padding
function Entry:pad_to_width()
  local total_padding = self.config.tab_width - self:rendered_width()

  local left_padding = (" "):rep(math.floor(total_padding / 2))
  local right_padding = (" "):rep(math.ceil(total_padding / 2))

  return left_padding, right_padding
end

---@return string
function Entry:make(tab)
  local separator = self.component_factory:separator(tab)
  local ft_icon = self.component_factory:ft_icon(tab)
  local name = self.component_factory:name(tab)
  local modified = self.component_factory:modified(tab)

  self.entry = separator .. ft_icon .. " " .. name .. " " .. modified
  local left_padding, right_padding = self:pad_to_width()

  return separator .. left_padding .. ft_icon .. " " .. name .. " " .. modified .. right_padding
end

return Entry
