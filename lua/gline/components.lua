---TODO: fix types for implementors of this interfaces functions
---@class Gline.Component
---@field init fun(self: Gline.Component, opts?: table<string, any>): Gline.Component constructor method, opts is different for each implementor
---@field make fun(self: Gline.Component, tab_info: Gline.TabInfo): string makes this components string given some tabinfo
---@field norm_hl string highlight used for normal tabs
---@field sel_hl string highlight used for the selected tab

---A table of components that gline uses by default
---@class Gline.DefaultComponents
local M = {}

---@class Gline.Component.Separator.Opts
---@field normal? {color: string, icon: string}
---@field selected? {color: string, icon: string}

---@class Gline.Component.Separator : Gline.Component
---@field normal {color: string, icon: string}
---@field selected {color: string, icon: string}
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

  if is_hex_color(self.normal.color) then
    norm_fg = self.normal.color
  else
    local sep_norm_hl = vim.api.nvim_get_hl(0, { name = self.normal.color, link = false })
    norm_fg = sep_norm_hl.fg
  end

  if is_hex_color(self.selected.color) then
    sel_fg = self.selected.color
  else
    local sep_sel_hl = vim.api.nvim_get_hl(0, { name = self.selected.color, link = false })
    sel_fg = sep_sel_hl.fg
  end

  vim.api.nvim_set_hl(
    0,
    "TabLineSep",
    vim.tbl_deep_extend("force", vim.api.nvim_get_hl(0, { name = "TabLine", link = false }), { fg = norm_fg })
  )
  vim.api.nvim_set_hl(
    0,
    "TabLineSelSep",
    vim.tbl_deep_extend("force", vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false }), { fg = sel_fg })
  )
end

---@param opts Gline.Component.Separator.Opts
function M.Separator:init(opts)
  local separator = setmetatable({}, M.Separator)
  separator.normal = opts.normal or {
    color = "VertSplit",
    icon = "▏",
  }
  separator.selected = opts.selected or {
    color = "Keyword",
    icon = "▎",
  }
  separator.norm_hl = "%#TabLineSep#"
  separator.sel_hl = "%#TabLineSelSep#"
  separator:set_highlights()

  return separator
end

function M.Separator:make(tab_info)
  return tab_info.is_selected and self.sel_hl .. self.selected.icon or self.norm_hl .. self.normal.icon
end

---@class Gline.Component.FtIcon.Opts
---@field colored? boolean

---@class Gline.Component.FtIcon : Gline.Component
---@field colored boolean
---@field devicons table
M.FtIcon = {}
M.FtIcon.__index = M.FtIcon

---@param opts Gline.Component.FtIcon.Opts
function M.FtIcon:init(opts)
  local ft_icon = setmetatable({}, M.FtIcon)
  if opts.colored == false then
    ft_icon.colored = false
    ft_icon.norm_hl = "%#TabLine#"
    ft_icon.sel_hl = "%#TabLineSel#"
  else
    ft_icon.colored = true
  end
  local success, devicons = pcall(require, "nvim-web-devicons")
  if not success then
    error("gline's filetype component requires having nvim-web-devicons installed")
  end
  ft_icon.devicons = devicons

  return ft_icon
end

function M.FtIcon:make(tab_info)
  local selected_buf_ft = vim.api.nvim_buf_get_option(tab_info.selected_buf, "ft")
  local icon_hl = tab_info.is_selected and vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false })
    or vim.api.nvim_get_hl(0, { name = "TabLine", link = false })

  local icon, icon_color, icon_hl_name
  icon, icon_color = self.devicons.get_icon_color_by_filetype(selected_buf_ft, { default = true })

  if self.colored then
    icon_hl_name = "TabLineIcon" .. selected_buf_ft .. (tab_info.is_selected and "Sel" or "")
    -- If we are making a tab for a filetype we haven't set highlight for before, set it now
    if vim.fn.hlexists(icon_hl_name) == 0 then
      vim.api.nvim_set_hl(0, icon_hl_name, vim.tbl_deep_extend("force", icon_hl, { fg = icon_color }))
    end
    icon_hl_name = "%#" .. icon_hl_name .. "#"
  else
    icon_hl_name = tab_info.is_selected and self.sel_hl or self.norm_hl
  end

  return icon_hl_name .. icon
end

---@class Gline.Component.BufName.Opts
---@field max_len? integer
---@field no_name_label? string

---@class Gline.Component.BufName : Gline.Component
---@field max_len integer
---@field no_name_label string
---@field norm_hl string
---@field sel_hl string
M.BufName = {}
M.BufName.__index = M.BufName

---@param opts Gline.Component.BufName.Opts
function M.BufName:init(opts)
  local buf_name = setmetatable({}, { __index = M.BufName })
  buf_name.max_len = opts.max_len or 16
  buf_name.no_name_label = opts.no_name_label or "[No Name]"
  buf_name.norm_hl = "%#TabLine#"
  buf_name.sel_hl = "%#TabLineSel#"

  return buf_name
end

function M.BufName:make(tab_info)
  local selected_buf_name = vim.fn.bufname(tab_info.selected_buf)
  local name = selected_buf_name == "" and self.no_name_label or vim.fn.fnamemodify(selected_buf_name, ":t")

  if #name > self.max_len then
    name = name:sub(1, self.max_len) .. "…"
  end

  return (tab_info.is_selected and self.sel_hl or self.norm_hl) .. name
end

---@class Gline.Component.Modified.Opts
---@field icon? string

---@class Gline.Component.Modified : Gline.Component
---@field icon string
---@field norm_hl string
---@field sel_hl string
M.Modified = {}
M.Modified.__index = M.Modified

---@param opts Gline.Component.Modified.Opts
function M.Modified:init(opts)
  local modified = setmetatable({}, { __index = M.Modified })
  modified.icon = opts.icon or "●"
  modified.norm_hl = "%#TabLine#"
  modified.sel_hl = "%#TabLineSel#"

  return modified
end

function M.Modified:make(tab_info)
  local icon = vim.api.nvim_buf_get_option(tab_info.selected_buf, "modified") and self.icon
    or string.rep(" ", vim.fn.strchars(self.icon))

  return (tab_info.is_selected and self.sel_hl or self.norm_hl) .. icon
end

return M
