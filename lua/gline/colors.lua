local config = require("gline").config

local M = {}

-- Only load colors for separators if enabled in user config
if config.separator.enabled then
  vim.api.nvim_set_hl(0, "TabLineSep", { fg = config.separator.inactive_color, bg = config.colors.inactive_bg })
  vim.api.nvim_set_hl(0, "TabLineSelSep", { fg = config.separator.active_color, bg = config.colors.active_bg }) -- TODO: active instead of sel everywhere

  M.sel_sep = "%#TabLineSelSep#"
  M.norm_sep = "%#TabLineSep#"
end

M.norm = "%#TabLine#"
M.sel = "%#TabLineSel#"
M.fill = "%#TabLineFill#"

M.active_bg = "#151515"
M.inactive_bg = "#000000"

return M
