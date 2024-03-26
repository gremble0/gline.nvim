local config = require("gline.config")
local colors = require("gline.colors")

---Used to make complete tab entries in the tabline. :make(tab) will return a string
---for that tabs information based on the users config
---@class Gline.TabFactory
---@field component_factories Gline.ComponentFactory[]
local M = { component_factories = {} }

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

---TODO make method
---@param s string
---@return string left_padding, string right_padding
local get_padding = function(s)
  local total_padding = config.entry_width - rendered_width(s)

  local left_padding = string.rep(" ", math.floor(total_padding / 2))
  local right_padding = string.rep(" ", math.ceil(total_padding / 2))

  return left_padding, right_padding
end

---@param tab Gline.TabInfo
---@return string string representation of a tab entry in the tabline
function M.make(tab)
  local components = {}
  for _, component_factory in ipairs(M.component_factories) do
    table.insert(components, component_factory:generate(tab))
  end

  local left_padding, right_padding = get_padding(table.concat(components, " "))

  table.insert(components, #config.config.sections.left, left_padding)
  table.insert(components, #config.config.sections.left + #config.config.sections.right, right_padding)

  return (tab.is_selected and colors.sel or colors.norm) .. table.concat(components, " ")
end

return M
