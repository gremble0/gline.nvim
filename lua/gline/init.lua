local config = require("gline.config")

---Used to make complete tab entries in the tabline. :make(tab) will return a string
---for that tabs information based on the users config
---@class Gline
---@field left_components Gline.Component[]
---@field center_components Gline.Component[]
---@field right_components Gline.Component[]
local M = { left_components = {}, center_components = {}, right_components = {} }

---This class is a mockup of the returntype of each element in vim.fn.gettabinfo() extended
---with some additional information
---@class Gline.TabInfo
---@field tabnr integer
---@field variables table<string, any>
---@field windows integer[]
---@field is_selected boolean
---@field selected_buf integer

---Get a list of tabinfo for all open tabs
---@return Gline.TabInfo[]
local get_tab_info = function()
  ---@type Gline.TabInfo[]
  local tab_infos = vim.fn.gettabinfo()
  for _, tab_info in ipairs(tab_infos) do
    tab_info.is_selected = tab_info.tabnr == vim.fn.tabpagenr()

    local buflist = vim.fn.tabpagebuflist(tab_info.tabnr)
    if type(buflist) == "number" then
      tab_info.selected_buf = buflist
    else
      local winnr = vim.fn.tabpagewinnr(tab_info.tabnr)
      tab_info.selected_buf = buflist[winnr]
    end
  end

  return tab_infos
end

_G.nvim_gline = function()
  local tabline_builder = ""

  for _, tab in ipairs(get_tab_info()) do
    tabline_builder = tabline_builder .. M.make_tab(tab)
  end

  return tabline_builder .. "%#TabLineFill#"
end

---@param section Gline.Config.SectionItem
---@param components Gline.Component[]
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
---@return string # string representation of a tab entry in the tabline
function M.make_tab(tab)
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

---@param conf Gline.Config?
M.setup = function(conf)
  config.merge_config(conf)
  M.init_components()

  vim.o.tabline = "%!v:lua.nvim_gline()"
end

return M
