local tabline = require("gline.tabline")
local config = require("gline.config")

local M = {}

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

M.tabline = function()
  local tabline_builder = ""

  for _, tab in ipairs(get_tab_info()) do
    tabline_builder = tabline_builder .. tabline.make(tab)
  end

  return tabline_builder .. "%#TabLineFill#"
end

---@param conf Gline.Config?
M.setup = function(conf)
  config.merge_config(conf)
  tabline.init_components()

  vim.o.tabline = "%!v:lua.require('gline').tabline()"
end

return M
