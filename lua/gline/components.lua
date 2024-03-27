local colors = require("gline.colors")

---@class Gline.Component
---@field init fun(self: Gline.Component, opts?: table): Gline.Component constructor method that initializes the factory
---@field make fun(self: Gline.Component, tab: Gline.TabInfo): string makes this components string given some tabinfo
---@field opts table<string, any>

---A table of components that gline uses by default
---@class Gline.DefaultComponents
local M = {}

---@class Gline.Component.Separator : Gline.Component
M.Separator = {}
M.Separator.__index = M.Separator

---Check if a string is a hex color. Vim highlights only accept 6 digit hex
---colors like #000000, so #000 will return false
---@return boolean
local is_hex_color = function(s)
  return s:match("^#%x%x%x%x%x%x$") ~= nil
end

---Set the highlights for separator components
function M.Separator:set_highlights()
  -- We need to dynamically change the background color based on selected and non
  -- selected tabs. Therefore we set the separators colors by overriding the
  -- tablines foreground colors with the active config.
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

function M.Separator:init(opts)
  local separator = setmetatable({}, M.Separator)
  separator.opts = opts or {}
  separator:set_highlights()

  return separator
end

function M.Separator:make(tab)
  return tab.is_selected and colors.sel_sep .. self.opts.selected.icon or colors.norm_sep .. self.opts.normal.icon
end

---@class Gline.Component.FtIcon : Gline.Component
---@field devicons table
M.FtIcon = {}
M.FtIcon.__index = M.FtIcon

function M.FtIcon:init(_)
  local ft_icon = setmetatable({}, M.FtIcon)
  local success, devicons = pcall(require, "nvim-web-devicons")
  if not success then
    error("Gline's filetype component requires having nvim-web-devicons installed")
  end
  ft_icon.devicons = devicons

  return ft_icon
end

function M.FtIcon:make(tab)
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

---@class Gline.Component.BufName : Gline.Component
M.BufName = {}
M.BufName.__index = M.BufName

function M.BufName:init(opts)
  local buf_name = setmetatable({}, { __index = M.BufName })
  buf_name.opts = opts or {}

  return buf_name
end

function M.BufName:make(tab)
  local selected_buf_name = vim.fn.bufname(tab.selected_buf)
  local name = selected_buf_name == "" and "[No Name]" or vim.fn.fnamemodify(selected_buf_name, ":t")

  if #name > self.opts.max_len then
    name = name:sub(1, self.opts.max_len) .. "…"
  end

  return (tab.is_selected and colors.sel or colors.norm) .. name
end

---@class Gline.Component.Modified : Gline.Component
M.Modified = {}
M.Modified.__index = M.Modified

function M.Modified:init(opts)
  local modified = setmetatable({}, { __index = M.Modified })
  modified.opts = opts or {}

  return modified
end

function M.Modified:make(tab)
  return vim.api.nvim_buf_get_option(tab.selected_buf, "modified") and self.opts.icon
    or string.rep(" ", vim.fn.strchars(self.opts.icon))
end

return M
