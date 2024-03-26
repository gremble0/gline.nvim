local colors = require("gline.colors")

---@type table<string, Gline.ComponentFactory>
local M = {}

---@class Gline.ComponentFactory
---@field init fun(self: Gline.ComponentFactory, opts?: table): Gline.ComponentFactory constructor method that initializes the factory
---@field make fun(self: Gline.ComponentFactory, tab: Gline.TabInfo): string makes this components string given some tabinfo
---@field opts table<string, any>

---@class Gline.Component.SeparatorFactory : Gline.ComponentFactory
M.SeparatorFactory = {}
M.SeparatorFactory.__index = M.SeparatorFactory

---Check if a string is a hex color
---@return boolean
local is_hex_color = function(s)
  return s:match("^#%x%x%x$") ~= nil or s:match("^#%x%x%x%x%x%x$") ~= nil
end

---Set the highlights for separator components
function M.SeparatorFactory:set_highlights()
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

  vim.api.nvim_set_hl(0, "TabLineSep", vim.tbl_deep_extend("force", colors.norm_hl, { fg = norm_fg }))
  vim.api.nvim_set_hl(0, "TabLineSelSep", vim.tbl_deep_extend("force", colors.sel_hl, { fg = sel_fg }))
end

function M.SeparatorFactory:init(opts)
  local separator_factory = setmetatable({}, M.SeparatorFactory)
  separator_factory.opts = opts or {}
  separator_factory:set_highlights()
  return separator_factory
end

function M.SeparatorFactory:make(tab)
  return tab.is_selected and colors.sel_sep .. self.opts.selected.icon or colors.norm_sep .. self.opts.normal.icon
end

---@class Gline.Component.FtIconFactory : Gline.ComponentFactory
---@field devicons table
M.FtIconFactory = {}
M.FtIconFactory.__index = M.FtIconFactory

function M.FtIconFactory:init(_)
  local ft_icon_factory = setmetatable({}, M.FtIconFactory)
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    error("ft_icon component requires nvim-web-devicons installed")
  end
  ft_icon_factory.devicons = devicons

  return ft_icon_factory
end

function M.FtIconFactory:make(tab)
  local selected_buf_ft = vim.api.nvim_buf_get_option(tab.selected_buf, "ft")
  local icon_hl = tab.is_selected and colors.sel_hl or colors.norm_hl

  local icon, icon_color = self.devicons.get_icon_color_by_filetype(selected_buf_ft, { default = true })
  local icon_hl_name = "TabLineIcon" .. selected_buf_ft .. (tab.is_selected and "Sel" or "")

  -- If we are making a tab for a filetype we haven't set before, set it now
  if vim.fn.hlexists(icon_hl_name) == 0 then
    vim.api.nvim_set_hl(0, icon_hl_name, vim.tbl_deep_extend("force", icon_hl, { fg = icon_color }))
  end

  return "%#" .. icon_hl_name .. "#" .. icon
end

---@class Gline.Component.BufNameFactory : Gline.ComponentFactory
M.BufNameFactory = {}
M.BufNameFactory.__index = M.BufNameFactory

function M.BufNameFactory:init(opts)
  local buf_name_factory = setmetatable({}, { __index = M.BufNameFactory })
  buf_name_factory.opts = opts or {}
  return buf_name_factory
end

function M.BufNameFactory:make(tab)
  local selected_buf_name = vim.fn.bufname(tab.selected_buf)
  local name = selected_buf_name == "" and "[No Name]" or vim.fn.fnamemodify(selected_buf_name, ":t")

  if #name > self.opts.max_len then
    name = name:sub(1, self.opts.max_len) .. "…"
  end

  return (tab.is_selected and colors.sel or colors.norm) .. name
end

---@class Gline.Component.ModifiedFactory : Gline.ComponentFactory
M.ModifiedFactory = {}
M.ModifiedFactory.__index = M.ModifiedFactory

function M.ModifiedFactory:init(opts)
  local modified_factory = setmetatable({}, { __index = M.ModifiedFactory })
  modified_factory.opts = opts or {}
  return modified_factory
end

function M.ModifiedFactory:make(tab)
  return vim.api.nvim_buf_get_option(tab.selected_buf, "modified") and self.opts.icon
    or string.rep(" ", vim.fn.strchars(self.opts.icon))
end

return M
