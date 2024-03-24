local Config = require("gline.config")
local Colors = require("gline.colors")

---Use one of this class' methods to make a component to put in a tab entry
---@class GLine.ComponentFactory
local ComponentFactory = {}
ComponentFactory.__index = ComponentFactory

---@return GLine.ComponentFactory
function ComponentFactory:new()
  local component = setmetatable({}, ComponentFactory)
  return component
end

---@param tab TabInfo
---@return string
function ComponentFactory:separator(tab)
  local selected = Config.separator.selected
  local normal = Config.separator.normal

  return tab.is_selected and (Colors.sel_sep .. selected.icon) or (Colors.norm_sep .. normal.icon)
end

---@param tab TabInfo
---@return string
function ComponentFactory:ft_icon(tab)
  local selected_buf_ft = vim.api.nvim_buf_get_option(tab.selected_buf, "ft")
  local icon_bg = tab.is_selected and Colors.sel_bg or Colors.norm_bg

  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    local icon_hl = "TabLineIconFallback" .. (tab.is_selected and "Sel" or "")
    if vim.fn.hlexists(icon_hl) == 0 then
      vim.api.nvim_set_hl(0, icon_hl, { fg = "#6d8086", bg = icon_bg })
    end

    return "%#" .. icon_hl .. "#" .. ""
  end

  local icon, icon_color = devicons.get_icon_color_by_filetype(selected_buf_ft, { default = true })
  local icon_hl = "TabLineIcon" .. selected_buf_ft .. (tab.is_selected and "Sel" or "")

  if vim.fn.hlexists(icon_hl) == 0 then
    vim.api.nvim_set_hl(0, icon_hl, { fg = icon_color, bg = icon_bg })
  end

  return "%#" .. icon_hl .. "#" .. icon
end

---@param tab TabInfo
---@return string
function ComponentFactory:name(tab)
  local selected_buf_name = vim.fn.bufname(tab.selected_buf)
  local name = selected_buf_name == "" and "[No Name]" or vim.fn.fnamemodify(selected_buf_name, ":t")

  if #name > Config.name.max_len then
    name = name:sub(1, Config.name.max_len) .. "…"
  end

  return (tab.is_selected and Colors.sel or Colors.norm) .. name
end

---@param tab TabInfo
---@return string
function ComponentFactory:modified(tab)
  return vim.api.nvim_buf_get_option(tab.selected_buf, "modified") and Config.modified.icon or ""
end

return ComponentFactory
