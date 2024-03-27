local config = require("gline.config")

---Used to make complete tab entries in the tabline. :make(tab) will return a string
---for that tabs information based on the users config
---@class Gline.TabLine
---@field left_components Gline.Component[]
---@field center_components Gline.Component[]
---@field right_components Gline.Component[]
local M = { left_components = {}, center_components = {}, right_components = {} }

local add_components = function(section, components)
  for _, section_item in ipairs(section) do
    local component = section_item[1]
    local opts = section_item[2]
    table.insert(components, component:init(opts))
  end
end

function M.init_components()
  add_components(config.sections.left, M.left_components)
  add_components(config.sections.center, M.center_components)
  add_components(config.sections.right, M.right_components)
end

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
---Get the padding around the center section
---@param s string
---@return string left_padding, string right_padding
local get_center_padding = function(s)
  -- Subtract the length of the sections as this will be added as padding between
  -- each component
  local n_total_padding = config.entry_width
    - rendered_width(s)
    - #config.sections.left
    - #config.sections.center
    - #config.sections.right

  local left_padding = string.rep(" ", math.floor(n_total_padding / 2))
  local right_padding = string.rep(" ", math.ceil(n_total_padding / 2))

  return left_padding, right_padding
end

---@param tab Gline.TabInfo
---@return string string representation of a tab entry in the tabline
function M.make(tab)
  local components = {}
  -- TODO: nested loop
  for _, factory in ipairs(M.left_components) do
    table.insert(components, factory:make(tab))
  end
  for _, factory in ipairs(M.center_components) do
    table.insert(components, factory:make(tab))
  end
  for _, factory in ipairs(M.right_components) do
    table.insert(components, factory:make(tab))
  end

  local tabline = table.concat(components, " ")
  local left_padding, right_padding = get_center_padding(tabline)

  table.insert(components, #config.sections.left + 1, left_padding)
  table.insert(components, #config.sections.left + #config.sections.center + 2, right_padding)
  table.insert(components, #config.config.sections.left + 1, "") -- One extra space of left padding
  table.insert(components, "") -- One extra space of right padding

  return table.concat(components, " ")
end

return M
