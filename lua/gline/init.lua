local ComponentFactory = require("gline.component_factory")
local EntryFactory = require("gline.entry_factory")
local Config = require("gline.config")

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

local is_hex_color = function(s)
  return s:match("^#%x%x%x$") ~= nil or s:match("^#%x%x%x%x%x%x$") ~= nil
end

---@param opts GlineConfig?
M.setup = function(opts)
  if opts then
    Config.merge_config(opts)
  end

  -- Only load colors for separators if enabled in user config
  if Config.config.separator.enabled then
    local tabline_hl = vim.api.nvim_get_hl(0, { name = "TabLine" })
    local tabline_sel_hl = vim.api.nvim_get_hl(0, { name = "TabLineSel" })

    if is_hex_color(Config.config.separator.selected.color) then
      vim.api.nvim_set_hl(
        0,
        "TabLineSelSep",
        { fg = Config.config.separator.selected.color, bg = string.format("#%06x", tabline_sel_hl.bg) }
      )
    else
      vim.api.nvim_set_hl(0, "TabLineSelSep", { link = Config.config.separator.selected.color })
    end

    if is_hex_color(Config.config.separator.normal.color) then
      vim.api.nvim_set_hl(
        0,
        "TabLineSep",
        { fg = Config.config.separator.normal.color, bg = string.format("#%06x", tabline_hl.bg) }
      )
    else
      vim.api.nvim_set_hl(0, "TabLineSep", { link = Config.config.separator.normal.color })
    end
  end

  vim.o.tabline = "%!v:lua.require('gline').tabline()"
end

return M
