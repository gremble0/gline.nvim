local Colors = require("gline.colors")
local Component = require("gline.component")
local Entry = require("gline.entry")
local Config = require("gline.config")

local M = {}

M.tabline = function()
  local tabline_builder = ""
  local colors = Colors(Config.config)
  local component_factory = Component:new(colors)
  for _, tab in ipairs(vim.fn.gettabinfo()) do
    tabline_builder = tabline_builder .. Entry:new(component_factory):make(tab)
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
