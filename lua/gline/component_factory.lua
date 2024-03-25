local config = require("gline.config")
local colors = require("gline.colors")
local devicons = nil

---Use one of this class' methods to make a component to put in a tab entry
---@class GLine.ComponentFactory
local ComponentFactory = {}
ComponentFactory.__index = ComponentFactory

---@return GLine.ComponentFactory
function ComponentFactory:new()
  local component = setmetatable({}, ComponentFactory)
  return component
end

---@param tab Gline.TabInfo
---@return string
function ComponentFactory:separator(tab)
  local selected = config.separator.selected
  local normal = config.separator.normal

  return tab.is_selected and (colors.sel_sep .. selected.icon) or (colors.norm_sep .. normal.icon)
end

---@param tab Gline.TabInfo
---@return string
function ComponentFactory:ft_icon(tab)
  local selected_buf_ft = vim.api.nvim_buf_get_option(tab.selected_buf, "ft")
  local icon_hl = tab.is_selected and colors.sel_hl or colors.norm_hl

  -- Try to load devicons, use fallback if fails, else cache it
  if devicons == nil then
    local ok, module = pcall(require, "nvim-web-devicons")
    if not ok then
      return "%#TabLineIconFallback" .. (tab.is_selected and "Sel" or "") .. "#" .. ""
    else
      devicons = module
    end
  end

  local icon, icon_color = devicons.get_icon_color_by_filetype(selected_buf_ft, { default = true })
  local icon_hl_name = "TabLineIcon" .. selected_buf_ft .. (tab.is_selected and "Sel" or "")

  -- If we are making a tab for a filetype we haven't set before, set it now
  if vim.fn.hlexists(icon_hl_name) == 0 then
    vim.api.nvim_set_hl(0, icon_hl_name, vim.tbl_deep_extend("force", icon_hl, { fg = icon_color }))
  end

  return "%#" .. icon_hl_name .. "#" .. icon
end

---@param tab Gline.TabInfo
---@return string
function ComponentFactory:name(tab)
  local selected_buf_name = vim.fn.bufname(tab.selected_buf)
  local name = selected_buf_name == "" and "[No Name]" or vim.fn.fnamemodify(selected_buf_name, ":t")

  if #name > config.name.max_len then
    name = name:sub(1, config.name.max_len) .. "…"
  end

  return (tab.is_selected and colors.sel or colors.norm) .. name
end

---@param tab Gline.TabInfo
---@return string
function ComponentFactory:modified(tab)
  return vim.api.nvim_buf_get_option(tab.selected_buf, "modified") and config.modified.icon or " "
end

return ComponentFactory
