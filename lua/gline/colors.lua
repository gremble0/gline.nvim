local Config = require("gline.config")

---@class Gline.Colors
local M = {
  norm = "%#TabLine#",
  sel = "%#TabLineSel#",
  fill = "%#TabLineFill#",
  sel_sep = "%#TabLineSelSep#",
  norm_sep = "%#TabLineSep#",

  -- should never error, every theme has TabLine hl groups
  sel_bg = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false }).bg,
  norm_bg = vim.api.nvim_get_hl(0, { name = "TabLine", link = false }).bg,
}

---Check if a string is a hex color
---@return boolean
local is_hex_color = function(s)
  return s:match("^#%x%x%x$") ~= nil or s:match("^#%x%x%x%x%x%x$") ~= nil
end

---Set the highlights for the separator component
local set_separator_highlights = function()
  -- We need to dynamically change the background color based on selected and non
  -- selected tabs, so the logic here is a bit convoluted, but we basically just
  -- set the background color dynamically and get the foreground from the config

  if is_hex_color(Config.separator.selected.color) then
    vim.api.nvim_set_hl(
      0,
      "TabLineSelSep",
      { fg = Config.separator.selected.color, bg = string.format("#%06x", M.sel_bg) }
    )
  else
    local sep_sel_fg = vim.api.nvim_get_hl(0, { name = Config.separator.selected.color, link = false }).fg
    vim.api.nvim_set_hl(0, "TabLineSelSep", { fg = sep_sel_fg, bg = string.format("#%06x", M.sel_bg) })
  end

  if is_hex_color(Config.separator.normal.color) then
    vim.api.nvim_set_hl(0, "TabLineSep", { fg = Config.separator.normal.color, bg = string.format("#%06x", M.norm_bg) })
  else
    local sep_norm_fg = vim.api.nvim_get_hl(0, { name = Config.separator.normal.color, link = false }).fg
    vim.api.nvim_set_hl(0, "TabLineSep", { fg = sep_norm_fg, bg = string.format("#%06x", M.norm_bg) })
  end
end

local set_ft_icon_highlights = function()
  -- local icon_hl = "TabLineIconFallback" .. (tab.is_selected and "Sel" or "")
  vim.api.nvim_set_hl(0, "TabLineIconFallbackSel", { fg = "#6d8086", bg = M.sel_bg })
  vim.api.nvim_set_hl(0, "TabLineIconFallback", { fg = "#6d8086", bg = M.norm_bg })
end

M.set_highlights = function()
  if Config.separator.enabled then
    set_separator_highlights()
  end
  if Config.ft_icon.enabled then
    set_ft_icon_highlights()
  end
end

return M
