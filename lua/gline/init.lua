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
local EntryFactory = lazy_require("gline.entry_factory")
local Config = require("gline.config")
local Colors = require("gline.colors")

local M = {}

---This class is a mockup of the returntype of each element in vim.fn.gettabinfo() extended
---with some additional information
---@class TabInfo
---@field tabnr integer
---@field variables table<string, any>
---@field windows integer[]
---@field is_selected boolean
---@field selected_buf integer

---@return TabInfo[]
local get_tab_info = function()
  ---@type TabInfo[]
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
  local entry_factory = EntryFactory:new(component_factory)

  for _, tab in ipairs(get_tab_info()) do
    tabline_builder = tabline_builder .. entry_factory:make(tab)
  end

  return tabline_builder .. Colors.fill
end

---@param conf Gline.Config?
M.setup = function(conf)
  Config.merge_config(conf)
  Colors.set_highlights()

  vim.o.tabline = "%!v:lua.require('gline').tabline()"
end

return M
