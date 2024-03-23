---@class GlineColors

---Check if a string is a hex color i.e. (#000..#fff or #000000..#ffffff)
---@param s string
local is_hex_color = function(s)
  return s:match("^#%x%x%x$") ~= nil or s:match("^#%x%x%x%x%x%x$") ~= nil
end

---@param config GlineConfig
---@return GlineColors
return function(config)
  local Colors = {}
  Colors.tabline_hl = vim.api.nvim_get_hl(0, { name = "TabLine" })
  Colors.tabline_sel_hl = vim.api.nvim_get_hl(0, { name = "TabLineSel" })

  Colors.norm = "%#TabLine#"
  Colors.sel = "%#TabLineSel#"
  Colors.fill = "%#TabLineFill#"

  -- Only load colors for separators if enabled in user config
  if config.separator.enabled then
    if is_hex_color(config.separator.selected.color) then
      vim.api.nvim_set_hl(
        0,
        "TabLineSelSep",
        { fg = config.separator.selected.color, bg = string.format("#%06x", Colors.tabline_sel_hl.bg) }
      )
    else
      vim.api.nvim_set_hl(0, "TabLineSelSep", { link = config.separator.selected.color })
    end

    if is_hex_color(config.separator.normal.color) then
      vim.api.nvim_set_hl(
        0,
        "TabLineSep",
        { fg = config.separator.normal.color, bg = string.format("#%06x", Colors.tabline_hl.bg) }
      )
    else
      vim.api.nvim_set_hl(0, "TabLineSep", { link = config.separator.normal.color })
    end

    Colors.sel_sep = "%#TabLineSelSep#"
    Colors.norm_sep = "%#TabLineSep#"
  end

  return Colors
end
