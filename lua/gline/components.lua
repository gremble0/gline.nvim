---@type table<string, Gline.ComponentFactory>
local M = {}

---TODO: M -> Component

---@class Gline.ComponentFactory
---@field new fun(self: Gline.ComponentFactory, opts?: table): Gline.ComponentFactory
---@field generate fun(self: Gline.ComponentFactory, tab_info: Gline.TabInfo): string

---@class Gline.Component.SeparatorFactory : Gline.ComponentFactory
M.SeparatorFactory = {
  ---Check if a string is a hex color
  ---@return boolean
  is_hex_color = function(self, s)
    return s:match("^#%x%x%x$") ~= nil or s:match("^#%x%x%x%x%x%x$") ~= nil
  end,

  ---Set the highlights for separator components
  set_separator_highlights = function(self)
    -- We need to dynamically change the background color based on selected and non
    -- selected tabs, so the logic here is a bit convoluted, but we basically just
    -- override the foreground colors of the tabline with the one specified in config
    local norm_fg, sel_fg

    if is_hex_color(self.opts.normal.color) then
      norm_fg = self.opts.normal.color
    else
      local sep_norm_hl = vim.api.nvim_get_hl(0, { name = self.opts.normal.color, link = false })
      norm_fg = sep_norm_hl.fg
    end

    if is_hex_color(self.opts.selected.color) then
      sel_fg = self.opts.selected.color
    else
      local sep_sel_hl = vim.api.nvim_get_hl(0, { name = self.opts.selected.color, link = false })
      sel_fg = sep_sel_hl.fg
    end

    vim.api.nvim_set_hl(0, "TabLineSep", vim.tbl_deep_extend("force", M.norm_hl, { fg = norm_fg }))
    vim.api.nvim_set_hl(0, "TabLineSelSep", vim.tbl_deep_extend("force", M.sel_hl, { fg = sel_fg }))
  end,

  new = function(self, opts)
    -- TODO: remove unnecessary setmetatable
    local separator_factory = setmetatable({}, { __index = M.SeparatorFactory })
    separator_factory.opts = opts or {}
    return separator_factory
  end,

  generate = function(self)
    return "|"
  end,
}

---@class Gline.Component.FtIconFactory : Gline.ComponentFactory
M.FtIconFactory = {
  new = function(self, opts)
    local ft_icon_factory = setmetatable({}, { __index = M.FtIconFactory })
    ft_icon_factory.opts = opts or {}
    return ft_icon_factory
  end,

  generate = function(self)
    return "#"
  end,
}

---@class Gline.Component.BufNameFactory : Gline.ComponentFactory
M.BufNameFactory = {
  new = function(self, opts)
    local buf_name_factory = setmetatable({}, { __index = M.BufNameFactory })
    buf_name_factory.opts = opts or {}
    return buf_name_factory
  end,

  generate = function(self)
    return "name"
  end,
}

---@class Gline.Component.ModifiedFactory : Gline.ComponentFactory
M.ModifiedFactory = {
  new = function(self, opts)
    local modified_factory = setmetatable({}, { __index = M.ModifiedFactory })
    modified_factory.opts = opts or {}
    return modified_factory
  end,

  generate = function(self)
    return "name"
  end,
}

return M
