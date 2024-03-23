local Config = require("gline.config")

---@class GlineColors
local M = {
  norm = "%#TabLine#",
  sel = "%#TabLineSel#",
  fill = "%#TabLineFill#",
  sel_sep = "%#TabLineSelSep#",
  norm_sep = "%#TabLineSep#",

  sel_bg = vim.api.nvim_get_hl(0, { name = "TabLineSel" }).bg, -- should never error, every theme has TabLine hl groups
  norm_bg = vim.api.nvim_get_hl(0, { name = "TabLine" }).bg, -- should never error, every theme has TabLine hl groups
}

local is_hex_color = function(s)
  return s:match("^#%x%x%x$") ~= nil or s:match("^#%x%x%x%x%x%x$") ~= nil
end

M.load_separator_colors = function()
  if is_hex_color(Config.config.separator.selected.color) then
    vim.api.nvim_set_hl(
      0,
      "TabLineSelSep",
      { fg = Config.config.separator.selected.color, bg = string.format("#%06x", M.sel_bg) }
    )
  else
    vim.api.nvim_set_hl(0, "TabLineSelSep", { link = Config.config.separator.selected.color })
  end

  if is_hex_color(Config.config.separator.normal.color) then
    vim.api.nvim_set_hl(
      0,
      "TabLineSep",
      { fg = Config.config.separator.normal.color, bg = string.format("#%06x", M.norm_bg) }
    )
  else
    vim.api.nvim_set_hl(0, "TabLineSep", { link = Config.config.separator.normal.color })
  end
end

return M
