---@class GLineComponentFactory
---@field config GlineConfig
---@field colors GlineColors
local ComponentFactory = {}
ComponentFactory.__index = ComponentFactory

---@param config GlineConfig
---@param colors GlineColors
---@return GLineComponentFactory
function ComponentFactory:new(config, colors)
  local component = setmetatable({}, ComponentFactory)
  component.config = config
  component.colors = colors
  return component
end

---@param tabpage integer
local function tabpage_get_selected_buf(tabpage)
  local buflist = vim.fn.tabpagebuflist(tabpage)
  local winnr = vim.fn.tabpagewinnr(tabpage)

  return type(buflist) == "number" and buflist or buflist[winnr]
end

local function name_trim_to_width(name, width)
  return #name > width and name:sub(1, width) .. "…" or name
end

function ComponentFactory:separator(tab)
  local selected = self.config.separator.selected
  local normal = self.config.separator.normal

  return tab.tabnr == vim.fn.tabpagenr() and (self.colors.sel_sep .. selected.icon)
    or (self.colors.norm_sep .. normal.icon)
end

function ComponentFactory:ft_icon(tab)
  local tabpage_is_selected = tab.tabnr == vim.fn.tabpagenr()
  local tabpage_sel_buf = tabpage_get_selected_buf(tab.tabnr)
  local buf_ft = vim.api.nvim_buf_get_option(tabpage_sel_buf, "ft")
  local icon_bg = tabpage_is_selected and self.colors.tabline_sel_hl.bg or self.colors.tabline_hl.bg

  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    local icon_hl = "TabLineIconFallback" .. (tabpage_is_selected and "Sel" or "")
    if vim.fn.hlexists(icon_hl) == 0 then
      vim.api.nvim_set_hl(0, icon_hl, { fg = "#6d8086", bg = icon_bg })
    end
    return "%#" .. icon_hl .. "#" .. ""
  end

  local icon, icon_color = devicons.get_icon_color_by_filetype(buf_ft, { default = true })
  local icon_hl = "TabLineIcon" .. buf_ft .. (tabpage_is_selected and "Sel" or "")

  if vim.fn.hlexists(icon_hl) == 0 then
    vim.api.nvim_set_hl(0, icon_hl, { fg = icon_color, bg = icon_bg })
  end

  return "%#" .. icon_hl .. "#" .. icon
end

function ComponentFactory:name(tab)
  local tabpage_is_selected = tab.tabnr == vim.fn.tabpagenr()
  local buf_name = vim.fn.bufname(tabpage_get_selected_buf(tab.tabnr))
  local name = buf_name == "" and "[No Name]" or vim.fn.fnamemodify(buf_name, ":t")
  return (tabpage_is_selected and self.colors.sel or self.colors.norm)
    .. name_trim_to_width(name, self.config.name.max_len)
end

function ComponentFactory:modified(tab)
  return vim.api.nvim_buf_get_option(tabpage_get_selected_buf(tab.tabnr), "modified") and self.config.modified.icon
    or ""
end

return ComponentFactory
