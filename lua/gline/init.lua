local ComponentFactory = require("gline.component_factory")
local EntryFactory = require("gline.entry_factory")
local Config = require("gline.config")
local Colors = require("gline.colors")

local M = {}

M.tabline = function()
  local tabline_builder = ""

  local component_factory = ComponentFactory:new()
  local entry_factory = EntryFactory:new(component_factory)

  for _, tab in ipairs(vim.fn.gettabinfo()) do
    tabline_builder = tabline_builder .. entry_factory:make(tab)
  end

  return tabline_builder .. "%#TabLineFill#"
end

---@param opts GlineConfig?
M.setup = function(opts)
  if opts then
    Config.config = vim.tbl_deep_extend("force", Config.config, opts)
  end

  -- Only load colors for separators if enabled in user config
  if Config.config.separator.enabled then
    Colors.load_separator_colors()
  end

  vim.o.tabline = "%!v:lua.require('gline').tabline()"
end

return M
