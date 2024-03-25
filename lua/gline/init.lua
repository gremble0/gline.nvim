---@param path string
---@return table
local lazy_require = function(path)
  return setmetatable({}, {
    __index = function(_, key)
      return require(path)[key]
    end,
    __newindex = function(_, key, value)
      require(path)[key] = value
    end,
  })
end

local ComponentFactory = lazy_require("gline.component_factory")
local TabFactory = lazy_require("gline.tab_factory")
local config = require("gline.config")
local colors = require("gline.colors")

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
    local winnr = vim.fn.tabpagewinnr(tab_info.tabnr)
    tab_info.selected_buf = type(buflist) == "number" and buflist or buflist[winnr]
  end

  return tab_infos
end

M.tabline = function()
  local tabline_builder = ""

  local component_factory = ComponentFactory:new()
  local tab_factory = TabFactory:new(component_factory)

  for _, tab in ipairs(get_tab_info()) do
    tabline_builder = tabline_builder .. tab_factory:make(tab)
  end

  return tabline_builder .. colors.fill
end

---@param conf Gline.Config?
M.setup = function(conf)
  config.merge_config(conf)
  colors.set_highlights()

  vim.o.tabline = "%!v:lua.require('gline').tabline()"
end

return M
