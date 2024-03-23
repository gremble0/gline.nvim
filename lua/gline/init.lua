local Colors = require("gline.colors")
local ComponentFactory = require("gline.component_factory")
local EntryFactory = require("gline.entry_factory")
local Config = require("gline.config")

local M = {}

M.tabline = function()
  local tabline_builder = ""
  local colors = Colors(Config.config)

  local component_factory = ComponentFactory:new(colors)
  local entry_factory = EntryFactory:new(component_factory)

  for _, tab in ipairs(vim.fn.gettabinfo()) do
    tabline_builder = tabline_builder .. entry_factory:make(tab)
  end

  return tabline_builder .. colors.fill
end

---@param opts GlineConfig?
M.setup = function(opts)
  if opts then
    Config.merge_config(opts)
  end

  vim.o.tabline = "%!v:lua.require('gline').tabline()"
end

return M
