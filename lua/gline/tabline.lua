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
  add_components(config.config.sections.left, M.left_components)
  add_components(config.config.sections.center, M.center_components)
  add_components(config.config.sections.right, M.right_components)
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
---@param s string
---@return string left_padding, string right_padding
local get_padding = function(s)
  local total_padding = config.entry_width - rendered_width(s)
  -- - #config.config.sections.left
  -- - #config.config.sections.center
  -- - #config.config.sections.right

  local left_padding = string.rep(" ", math.floor(total_padding / 2))
  local right_padding = string.rep(" ", math.ceil(total_padding / 2))

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

  -- table.insert(components, #config.config.sections.left + 1, " ") -- One extra space of left padding
  -- table.insert(components, " ") -- One extra space of right padding

  local tabline = table.concat(components, " ")
  local left_padding, right_padding = get_padding(tabline)

  table.insert(components, #config.config.sections.left + 1, left_padding)
  table.insert(components, #config.config.sections.left + #config.config.sections.center + 2, right_padding)

  print(vim.inspect(components))

  return (tab.is_selected and "%#TabLineSel#" or "%#TabLine#") .. table.concat(components, " ")
end

return M
