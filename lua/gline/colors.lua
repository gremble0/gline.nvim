local config = require("gline.config")

---@class Gline.Colors
local M = {
  norm = "%#TabLine#",
  sel = "%#TabLineSel#",
  fill = "%#TabLineFill#",
  sel_sep = "%#TabLineSelSep#",
  norm_sep = "%#TabLineSep#",

  -- should never error, every theme has TabLine hl groups
  sel_hl = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false }),
  norm_hl = vim.api.nvim_get_hl(0, { name = "TabLine", link = false }),
}

---Check if a string is a hex color
---@return boolean
local is_hex_color = function(s)
  return s:match("^#%x%x%x$") ~= nil or s:match("^#%x%x%x%x%x%x$") ~= nil
end

---Set the highlights for separator components
local set_separator_highlights = function()
  -- We need to dynamically change the background color based on selected and non
  -- selected tabs, so the logic here is a bit convoluted, but we basically just
  -- override the foreground colors of the tabline with the one specified in config
  local separator = config.separator
  local norm_fg, sel_fg

  if is_hex_color(separator.normal.color) then
    norm_fg = separator.normal.color
  else
    local sep_norm_hl = vim.api.nvim_get_hl(0, { name = separator.normal.color, link = false })
    norm_fg = sep_norm_hl.fg
  end

  if is_hex_color(separator.selected.color) then
    sel_fg = separator.selected.color
  else
    local sep_sel_hl = vim.api.nvim_get_hl(0, { name = separator.selected.color, link = false })
    sel_fg = sep_sel_hl.fg
  end

  vim.api.nvim_set_hl(0, "TabLineSep", vim.tbl_deep_extend("force", M.norm_hl, { fg = norm_fg }))
  vim.api.nvim_set_hl(0, "TabLineSelSep", vim.tbl_deep_extend("force", M.sel_hl, { fg = sel_fg }))
end

local set_ft_icon_highlights = function()
  -- Set highlights for fallback icons
  vim.api.nvim_set_hl(0, "TabLineIconFallback", vim.tbl_deep_extend("force", M.norm_hl, { fg = "#6d8086" }))
  vim.api.nvim_set_hl(0, "TabLineIconFallbackSel", vim.tbl_deep_extend("force", M.sel_hl, { fg = "#6d8086" }))
end

M.set_highlights = function()
  if config.separator.enabled then
    set_separator_highlights()
  end
  if config.ft_icon.enabled then
    set_ft_icon_highlights()
  end
end

return M
