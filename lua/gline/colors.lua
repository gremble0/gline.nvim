local config = require("gline").config

local M = {}

---Check if a string is a hex color i.e. (#000..#fff or #000000..#ffffff)
---@param s string
local is_hex_color = function(s)
  return s:match("^#%x%x%x$") ~= nil or s:match("^#%x%x%x%x%x%x$") ~= nil
end

-- Only load colors for separators if enabled in user config
if config.separator.enabled then
  if is_hex_color(config.separator.selected.color) then
    vim.api.nvim_set_hl(0, "TabLineSelSep", { fg = config.separator.selected.color })
  else
    vim.api.nvim_set_hl(0, "TabLineSelSep", { link = config.separator.selected.color })
  end

  if is_hex_color(config.separator.normal.color) then
    vim.api.nvim_set_hl(0, "TabLineSep", { fg = config.separator.normal.color })
  else
    vim.api.nvim_set_hl(0, "TabLineSep", { link = config.separator.normal.color })
  end

  M.sel_sep = "%#TabLineSelSep#"
  M.norm_sep = "%#TabLineSep#"
end

M.norm = "%#TabLine#"
M.sel = "%#TabLineSel#"
M.fill = "%#TabLineFill#"

return M
