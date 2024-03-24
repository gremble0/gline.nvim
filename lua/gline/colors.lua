local Config = require("gline.config")

---@class Gline.Colors
local M = {
  norm = "%#TabLine#",
  sel = "%#TabLineSel#",
  fill = "%#TabLineFill#",
  sel_sep = "%#TabLineSelSep#",
  norm_sep = "%#TabLineSep#",

  -- should never error, every theme has TabLine hl groups
  sel_bg = vim.api.nvim_get_hl(0, { name = "TabLineSel" }).bg,
  norm_bg = vim.api.nvim_get_hl(0, { name = "TabLine" }).bg,
}

local is_hex_color = function(s)
  return s:match("^#%x%x%x$") ~= nil or s:match("^#%x%x%x%x%x%x$") ~= nil
end

local set_separator_highlights = function()
  if is_hex_color(Config.separator.selected.color) then
    vim.api.nvim_set_hl(
      0,
      "TabLineSelSep",
      { fg = Config.separator.selected.color, bg = string.format("#%06x", M.sel_bg) }
    )
  else
    -- Use foreground from configs highlight group, use background from theme's TabLineSel
    local sep_sel_fg = vim.api.nvim_get_hl(0, { name = Config.separator.selected.color }).fg
    vim.api.nvim_set_hl(0, "TabLineSelSep", { fg = sep_sel_fg, bg = string.format("#%06x", M.sel_bg) })
  end

  if is_hex_color(Config.separator.normal.color) then
    vim.api.nvim_set_hl(0, "TabLineSep", { fg = Config.separator.normal.color, bg = string.format("#%06x", M.norm_bg) })
  else
    -- Use foreground from configs highlight group, use background from theme's TabLine
    local sep_norm_fg = vim.api.nvim_get_hl(0, { name = Config.separator.normal.color }).fg
    vim.api.nvim_set_hl(0, "TabLineSep", { fg = sep_norm_fg, bg = string.format("#%06x", M.norm_bg) })
  end
end

M.set_highlights = function()
  if Config.separator.enabled then
    set_separator_highlights()
  end
end

return M
