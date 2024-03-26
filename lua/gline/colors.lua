---@class Gline.Colors
return {
  norm = "%#TabLine#",
  sel = "%#TabLineSel#",
  fill = "%#TabLineFill#",
  sel_sep = "%#TabLineSelSep#",
  norm_sep = "%#TabLineSep#",

  -- should never error, every theme has TabLine hl groups
  sel_hl = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false }),
  norm_hl = vim.api.nvim_get_hl(0, { name = "TabLine", link = false }),
}
