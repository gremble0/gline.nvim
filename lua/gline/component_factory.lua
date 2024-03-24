local Config = require("gline.config")
local Colors = require("gline.colors")

---Use one of this class' methods to make a component to put in a tab entry
---@class GLine.ComponentFactory
local ComponentFactory = {}
ComponentFactory.__index = ComponentFactory

---This class is a mockup of the returntype of each element in vim.fn.gettabinfo()
---@class Tab
---@field tabnr integer
---@field variables table<string, any>
---@field windows integer[]

---@return GLine.ComponentFactory
function ComponentFactory:new()
  local component = setmetatable({}, ComponentFactory)
  return component
end

---@param tabpage integer
---@return integer
local function tabpage_get_selected_buf(tabpage)
  local buflist = vim.fn.tabpagebuflist(tabpage)
  local winnr = vim.fn.tabpagewinnr(tabpage)

  return type(buflist) == "number" and buflist or buflist[winnr]
end

---@param name string
---@param width integer
---@return string
local function name_trim_to_width(name, width)
  return #name > width and name:sub(1, width) .. "…" or name
end

---@param tab Tab
---@return string
function ComponentFactory:separator(tab)
  local selected = Config.separator.selected
  local normal = Config.separator.normal

  return tab.tabnr == vim.fn.tabpagenr() and (Colors.sel_sep .. selected.icon) or (Colors.norm_sep .. normal.icon)
end

---@param tab Tab
---@return string
function ComponentFactory:ft_icon(tab)
  local tabpage_is_selected = tab.tabnr == vim.fn.tabpagenr()
  local tabpage_sel_buf = tabpage_get_selected_buf(tab.tabnr)
  local buf_ft = vim.api.nvim_buf_get_option(tabpage_sel_buf, "ft")
  local icon_bg = tabpage_is_selected and Colors.sel_bg or Colors.norm_bg

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

---@param tab Tab
---@return string
function ComponentFactory:name(tab)
  local tabpage_is_selected = tab.tabnr == vim.fn.tabpagenr()
  local buf_name = vim.fn.bufname(tabpage_get_selected_buf(tab.tabnr))
  local name = buf_name == "" and "[No Name]" or vim.fn.fnamemodify(buf_name, ":t")

  return (tabpage_is_selected and Colors.sel or Colors.norm) .. name_trim_to_width(name, Config.name.max_len)
end

---@param tab Tab
---@return string
function ComponentFactory:modified(tab)
  return vim.api.nvim_buf_get_option(tabpage_get_selected_buf(tab.tabnr), "modified") and Config.modified.icon or ""
end

return ComponentFactory
