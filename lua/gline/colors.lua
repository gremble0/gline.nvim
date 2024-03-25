local Config = require("gline.config")

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

---Set the highlights for the separator component
local set_separator_highlights = function()
  -- We need to dynamically change the background color based on selected and non
  -- selected tabs, so the logic here is a bit convoluted, but we basically just
  -- set the background color dynamically and get the foreground from the config
  local separator = Config.separator

  if is_hex_color(separator.selected.color) then
    vim.api.nvim_set_hl(0, "TabLineSelSep", vim.tbl_deep_extend("force", M.sel_hl, { fg = separator.selected.color }))
  else
    local sep_sel_hl = vim.api.nvim_get_hl(0, { name = separator.selected.color, link = false })
    -- sepsel_hl.fg can error if user gives invalid config, skill issue
    vim.api.nvim_set_hl(0, "TabLineSelSep", vim.tbl_deep_extend("force", M.sel_hl, { fg = sep_sel_hl.fg }))
  end

  if is_hex_color(separator.normal.color) then
    vim.api.nvim_set_hl(0, "TabLineSep", vim.tbl_deep_extend("force", M.norm_hl, { fg = separator.normal.color }))
  else
    local sep_norm_hl = vim.api.nvim_get_hl(0, { name = separator.normal.color, link = false })
    vim.api.nvim_set_hl(0, "TabLineSep", vim.tbl_deep_extend("force", M.norm_hl, { fg = sep_norm_hl.fg }))
  end
end

local set_ft_icon_highlights = function()
  vim.api.nvim_set_hl(0, "TabLineIconFallbackSel", vim.tbl_deep_extend("force", M.sel_hl, { fg = "#6d8086" }))
  vim.api.nvim_set_hl(0, "TabLineIconFallback", vim.tbl_deep_extend("force", M.norm_hl, { fg = "#6d8086" }))
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
